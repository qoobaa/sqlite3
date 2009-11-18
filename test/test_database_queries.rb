require "helper"

class TestDatabaseQueries < Test::Unit::TestCase
  def setup
    @db = SQLite3::Database.new(":memory:", :utf16 => true)
    @db.execute("CREATE TABLE t1(id INTEGER PRIMARY KEY ASC, t TEXT, nu NUMERIC, i INTEGER, no BLOB)")
  end

  def test_tables_empty
    assert_equal [], @db.execute("SELECT * FROM t1")
  end

  def test_execute
    @db.execute("INSERT INTO t1 VALUES(NULL, 'text1', 1.22, 42, NULL)")
    rows = @db.execute("SELECT * FROM t1")
    assert_equal 1, rows.size
    row = rows[0]
    assert_equal "text1", row[1]
    assert_equal "1.22", row[2]
    assert_equal "42", row[3]
    assert_nil row[4]
  end

  def test_execute_with_bindings
    blob = open("test/fixtures/SQLite.gif", "rb").read
    @db.execute("INSERT INTO t1 VALUES(?, ?, ?, ?, ?)", nil, "text1", 1.22, 42, blob)
    rows = @db.execute("SELECT * FROM t1")
    assert_equal 1, rows.size
    row = rows[0]
    assert_equal "text1", row[1]
    assert_equal "1.22", row[2]
    assert_equal "42", row[3]
    assert_equal blob, row[4]
  end

  def test_execute_with_different_encodings
    expected_string = "text1"
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL)", expected_string.encode(Encoding::ASCII_8BIT))
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_8))
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_16LE))
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_16BE))
    rows = @db.execute("SELECT * FROM t1")
    assert_equal 4, rows.size
    strings = rows.map { |row| row[1] }
    assert_equal [expected_string] * 4, strings
  end

  def test_execute_with_bad_query
    assert_raise(SQLite3::SQLException) { @db.execute("bad query") }
    assert_equal %Q{near "bad": syntax error}, @db.errmsg
    assert_equal 1, @db.errcode
  end

  # def test_execute_with_closed_database
  #   @db.close
  #   @db.execute("SELECT * FROM t1")
  # end

  def test_trace_handler
    original_query = "SELECT * FROM t1"
    @db.trace { |data, sql| @traced_data, @traced_query = data, sql }
    @db.execute(original_query)
    assert_equal original_query, @traced_query
  end

  # def test_busy_handler
  #   original_query = "SELECT * FROM t1"
  #   @db.busy_handler { |data, timeout| puts data, timeout; 0 }
  # end

  def test_authorizer
    @db.execute("INSERT INTO t1 VALUES(NULL, 'text1', 1.22, 42, NULL)")
    @db.authorizer { 0 }
    assert_nothing_raised { @rows = @db.execute("SELECT * FROM t1") }
    assert_equal 1, @rows.size
    @db.authorizer { 1 }
    assert_raises(SQLite3::AuthorizationException) { @db.execute("SELECT * FROM t1") }
    @db.authorizer { 2 }
    assert_nothing_raised { @rows = @db.execute("SELECT * FROM t1") }
    assert_equal 0, @rows.size
  end
end
