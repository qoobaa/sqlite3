module SQLite3

  # The Database class encapsulates a single connection to a SQLite3 database.
  # Its usage is very straightforward:
  #
  #   require "sqlite3"
  #
  #   db = SQLite3::Database.new("data.db")
  #
  #   db.execute("select * from table") do |row|
  #     p row
  #   end
  #
  #   db.close
  #
  # It wraps the lower-level methods provides by the selected driver, and
  # includes the Pragmas module for access to various pragma convenience
  # methods.
  #
  # The Database class provides type translation services as well, by which
  # the SQLite3 data types (which are all represented as strings) may be
  # converted into their corresponding types (as defined in the schemas
  # for their tables). This translation only occurs when querying data from
  # the database--insertions and updates are all still typeless.
  #
  # Furthermore, the Database class has been designed to work well with the
  # ArrayFields module from Ara Howard. If you require the ArrayFields
  # module before performing a query, and if you have not enabled results as
  # hashes, then the results will all be indexible by field name.
  class Database
    include Pragmas

    class << self

      alias :open :new

      # Quotes the given string, making it safe to use in an SQL statement.
      # It replaces all instances of the single-quote character with two
      # single-quote characters. The modified string is returned.
      def quote(string)
        string.gsub(/'/, "''")
      end

    end

    # The low-level opaque database handle that this object wraps.
    attr_reader :handle

    # A reference to the underlying SQLite3 driver used by this database.
    attr_reader :driver

    # A boolean that indicates whether rows in result sets should be returned
    # as hashes or not. By default, rows are returned as arrays.
    attr_accessor :results_as_hash

    # A boolean indicating whether or not type translation is enabled for this
    # database.
    attr_accessor :type_translation

    # Encoding used to comunicate with database.
    attr_reader :encoding

    # Create a new Database object that opens the given file. If utf16
    # is +true+, the filename is interpreted as a UTF-16 encoded string.
    #
    # By default, the new database will return result rows as arrays
    # (#results_as_hash) and has type translation disabled (#type_translation=).
    def initialize(file_name, options = {})
      @encoding = Encoding.find(options.fetch(:encoding, "utf-8"))

      load_driver(options[:driver])

      @statement_factory = options[:statement_factory] || Statement

      result, @handle = @driver.open(file_name, Encoding.utf_16?(@encoding))
      Error.check(result, self, "could not open database")

      @closed = false
      @results_as_hash = options.fetch(:results_as_hash, false)
      @type_translation = options.fetch(:type_translation, false)
      @translator = nil
      @transaction_active = false
    end

    # Return +true+ if the string is a valid (ie, parsable) SQL statement, and
    # +false+ otherwise
    def complete?(string)
      @driver.complete?(string)
    end

    # Return a string describing the last error to have occurred with this
    # database.
    def errmsg
      @driver.errmsg(@handle)
    end

    # Return an integer representing the last error to have occurred with this
    # database.
    def errcode
      @driver.errcode(@handle)
    end

    # Return the type translator employed by this database instance. Each
    # database instance has its own type translator; this allows for different
    # type handlers to be installed in each instance without affecting other
    # instances. Furthermore, the translators are instantiated lazily, so that
    # if a database does not use type translation, it will not be burdened by
    # the overhead of a useless type translator. (See the Translator class.)
    def translator
      @translator ||= Translator.new
    end

    # Closes this database.
    def close
      unless @closed
        result = @driver.close(@handle)
        Error.check(result, self)
      end
      @closed = true
    end

    # Returns +true+ if this database instance has been closed (see #close).
    def closed?
      @closed
    end

    # Returns a Statement object representing the given SQL. This does not
    # execute the statement; it merely prepares the statement for execution.
    #
    # The Statement can then be executed using Statement#execute.
    #
    def prepare(sql)
      stmt = @statement_factory.new(self, sql, Encoding.utf_16?(@encoding))
      if block_given?
        begin
          yield stmt
        ensure
          stmt.close
        end
      else
        return stmt
      end
    end

    # Executes the given SQL statement. If additional parameters are given,
    # they are treated as bind variables, and are bound to the placeholders in
    # the query.
    #
    # Note that if any of the values passed to this are hashes, then the
    # key/value pairs are each bound separately, with the key being used as
    # the name of the placeholder to bind the value to.
    #
    # The block is optional. If given, it will be invoked for each row returned
    # by the query. Otherwise, any results are accumulated into an array and
    # returned wholesale.
    #
    # See also #execute2, #query, and #execute_batch for additional ways of
    # executing statements.
    def execute(sql, *bind_vars)
      prepare(sql) do |stmt|
        result = stmt.execute(*bind_vars)
        if block_given?
          result.each { |row| yield row }
        else
          return result.inject([]) { |arr, row| arr << row; arr }
        end
      end
    end

    # Executes the given SQL statement, exactly as with #execute. However, the
    # first row returned (either via the block, or in the returned array) is
    # always the names of the columns. Subsequent rows correspond to the data
    # from the result set.
    #
    # Thus, even if the query itself returns no rows, this method will always
    # return at least one row--the names of the columns.
    #
    # See also #execute, #query, and #execute_batch for additional ways of
    # executing statements.
    def execute2(sql, *bind_vars)
      prepare(sql) do |stmt|
        result = stmt.execute(*bind_vars)
        if block_given?
          yield result.columns
          result.each { |row| yield row }
        else
          return result.inject([result.columns]) { |arr,row| arr << row; arr }
        end
      end
    end

    # Executes all SQL statements in the given string. By contrast, the other
    # means of executing queries will only execute the first statement in the
    # string, ignoring all subsequent statements. This will execute each one
    # in turn. The same bind parameters, if given, will be applied to each
    # statement.
    #
    # This always returns +nil+, making it unsuitable for queries that return
    # rows.
    def execute_batch(sql, *bind_vars)
      sql = sql.strip
      until sql.empty? do
        prepare(sql) do |stmt|
          stmt.execute(*bind_vars)
          sql = stmt.remainder.strip
        end
      end
      nil
    end

    # This is a convenience method for creating a statement, binding
    # paramters to it, and calling execute:
    #
    #   result = db.query("select * from foo where a=?", 5)
    #   # is the same as
    #   result = db.prepare("select * from foo where a=?").execute(5)
    #
    # You must be sure to call +close+ on the ResultSet instance that is
    # returned, or you could have problems with locks on the table. If called
    # with a block, +close+ will be invoked implicitly when the block
    # terminates.
    def query(sql, *bind_vars)
      result = prepare(sql).execute(*bind_vars)
      if block_given?
        begin
          yield result
        ensure
          result.close
        end
      else
        return result
      end
    end

    # A convenience method for obtaining the first row of a result set, and
    # discarding all others. It is otherwise identical to #execute.
    #
    # See also #get_first_value.
    def get_first_row(sql, *bind_vars)
      execute(sql, *bind_vars) { |row| return row }
      nil
    end

    # A convenience method for obtaining the first value of the first row of a
    # result set, and discarding all other values and rows. It is otherwise
    # identical to #execute.
    #
    # See also #get_first_row.
    def get_first_value(sql, *bind_vars)
      execute(sql, *bind_vars) { |row| return row[0] }
      nil
    end

    # Obtains the unique row ID of the last row to be inserted by this Database
    # instance.
    def last_insert_row_id
      @driver.last_insert_rowid(@handle)
    end

    # Returns the number of changes made to this database instance by the last
    # operation performed. Note that a "delete from table" without a where
    # clause will not affect this value.
    def changes
      @driver.changes(@handle)
    end

    # Returns the total number of changes made to this database instance
    # since it was opened.
    def total_changes
      @driver.total_changes(@handle)
    end

    # Interrupts the currently executing operation, causing it to abort.
    def interrupt
      @driver.interrupt(@handle)
    end

    # Indicates that if a request for a resource terminates because that
    # resource is busy, SQLite should sleep and retry for up to the indicated
    # number of milliseconds. By default, SQLite does not retry
    # busy resources. To restore the default behavior, send 0 as the
    # +ms+ parameter.
    #
    # See also the mutually exclusive #busy_handler.
    def busy_timeout(ms)
      result = @driver.busy_timeout(@handle, ms)
      Error.check(result, self)
    end

    # Begins a new transaction. Note that nested transactions are not allowed
    # by SQLite, so attempting to nest a transaction will result in a runtime
    # exception.
    #
    # The +mode+ parameter may be either <tt>:deferred</tt> (the default),
    # <tt>:immediate</tt>, or <tt>:exclusive</tt>.
    #
    # If a block is given, the database instance is yielded to it, and the
    # transaction is committed when the block terminates. If the block
    # raises an exception, a rollback will be performed instead. Note that if
    # a block is given, #commit and #rollback should never be called
    # explicitly or you'll get an error when the block terminates.
    #
    # If a block is not given, it is the caller's responsibility to end the
    # transaction explicitly, either by calling #commit, or by calling
    # #rollback.
    def transaction(mode = :deferred)
      execute "begin #{mode.to_s} transaction"
      @transaction_active = true

      if block_given?
        abort = false
        begin
          yield self
        rescue ::Object
          abort = true
          raise
        ensure
          abort and rollback or commit
        end
      end

      true
    end

    # Commits the current transaction. If there is no current transaction,
    # this will cause an error to be raised. This returns +true+, in order
    # to allow it to be used in idioms like
    # <tt>abort? and rollback or commit</tt>.
    def commit
      execute "commit transaction"
      @transaction_active = false
      true
    end

    # Rolls the current transaction back. If there is no current transaction,
    # this will cause an error to be raised. This returns +true+, in order
    # to allow it to be used in idioms like
    # <tt>abort? and rollback or commit</tt>.
    def rollback
      execute "rollback transaction"
      @transaction_active = false
      true
    end

    # Returns +true+ if there is a transaction active, and +false+ otherwise.
    def transaction_active?
      @transaction_active
    end

    private

    # Loads the corresponding driver, or if it is nil, attempts to locate a
    # suitable driver.
    def load_driver(driver)
      case driver
      when Class
        # do nothing--use what was given
      when Symbol, String
        require "sqlite3/driver/#{driver.to_s.downcase}/driver"
        driver = SQLite3::Driver.const_get(driver)::Driver
      else
        ["FFI"].each do |d|
          begin
            require "sqlite3/driver/#{d.downcase}/driver"
            driver = SQLite3::Driver.const_get(d)::Driver
            break
          rescue SyntaxError
            raise
          rescue ScriptError, Exception, NameError
          end
        end
        raise "no driver for sqlite3 found" unless driver
      end

      @driver = driver.new
    end

  end
end

