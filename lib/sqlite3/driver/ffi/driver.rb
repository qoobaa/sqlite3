require 'sqlite3/driver/ffi/api'

module SQLite3 ; module Driver ; module FFI

  class Driver
    STATIC    =  0
    TRANSIENT = -1

    def open(filename, utf16 = false)
      handle = ::FFI::MemoryPointer.new(:pointer)
      result = API.send((utf16 ? :sqlite3_open16 : :sqlite3_open), filename, handle)
      [result, handle.get_pointer(0)]
    end

    def errmsg(db, utf16 = false)
      if utf16
        msg = API.sqlite3_errmsg16(db)
        msg.free = nil
        msg.to_s(utf16_length(msg))
      else
        API.sqlite3_errmsg(db)
      end
    end

    def prepare(db, sql, utf16 = false)
      handle = ::FFI::MemoryPointer.new(:pointer)
      remainder = ::FFI::MemoryPointer.new(:pointer)

      result = API.send((utf16 ? :sqlite3_prepare16 : :sqlite3_prepare), db, sql, sql.length, handle, remainder)

      args = utf16 ? [utf16_length(remainder)] : []
      remainder = remainder.to_s(*args)

      [result, handle.get_pointer(0), remainder]
    end

    def complete?(sql, utf16 = false)
      API.send(utf16 ? :sqlite3_complete16 : :sqlite3_complete, sql)
    end

    def value_blob(value)
      blob = API.sqlite3_value_blob(value)
      blob.free = nil
      blob.to_s(API.sqlite3_value_bytes(value))
    end

    def value_text(value, utf16 = false)
      method = case utf16
               when nil, false
                 :sqlite3_value_text
               when :le
                 :sqlite3_value_text16le
               when :be
                 :sqlite3_value_text16be
               else
                 :sqlite3_value_text16
               end

      result = API.send(method, value)
      if utf16
        result.free = nil
        size = API.sqlite3_value_bytes(value)
        result = result.to_s(size)
      end

      result
    end

    def column_blob(stmt, column)
      blob = API.sqlite3_column_blob(stmt, column)
      blob.free = nil
      blob.to_s(API.sqlite3_column_bytes(stmt, column))
    end

    def result_text(func, text, utf16 = false)
      method = case utf16
               when false, nil
                 :sqlite3_result_text
               when :le
                 :sqlite3_result_text16le
               when :be
                 :sqlite3_result_text16be
               else
                 :sqlite3_result_text16
               end

      s = text.to_s
      API.send(method, func, s, s.length, TRANSIENT)
    end

    def busy_handler(db, data = nil, &block)
      @busy_handler = block

      unless @busy_handler_callback
        @busy_handler_callback = ::DL.callback("IPI") do |cookie, timeout|
          @busy_handler.call(cookie, timeout) || 0
        end
      end

      API.sqlite3_busy_handler(db, block&&@busy_handler_callback, data)
    end

    def set_authorizer(db, data = nil, &block)
      @authorizer_handler = block

      unless @authorizer_handler_callback
        @authorizer_handler_callback = ::DL.callback("IPIPPPP") do |cookie,mode,a,b,c,d|
          @authorizer_handler.call(cookie, mode, a&&a.to_s, b&&b.to_s, c&&c.to_s, d&&d.to_s) || 0
        end
      end

      API.sqlite3_set_authorizer(db, block&&@authorizer_handler_callback, data)
    end

    def trace(db, data = nil, &block)
      @trace_handler = block

      unless @trace_handler_callback
        @trace_handler_callback = ::DL.callback("IPS") do |cookie,sql|
          @trace_handler.call(cookie ? cookie.to_object : nil, sql) || 0
        end
      end

      API.sqlite3_trace(db, block&&@trace_handler_callback, data)
    end

    def create_function(db, name, args, text, cookie, func, step, final)
      # begin
      if @func_handler_callback.nil? && func
        @func_handler_callback = ::DL.callback("0PIP") do |context,nargs,args|
          args = args.to_s(nargs*4).unpack("L*").map {|i| ::FFI::MemoryPointer.new(i)}
          data = API.sqlite3_user_data(context).to_object
          data[:func].call(context, *args)
        end
      end

      if @step_handler_callback.nil? && step
        @step_handler_callback = ::DL.callback("0PIP") do |context,nargs,args|
          args = args.to_s(nargs*4).unpack("L*").map {|i| ::FFI::MemoryPointer.new(i)}
          data = API.sqlite3_user_data(context).to_object
          data[:step].call(context, *args)
        end
      end

      if @final_handler_callback.nil? && final
        @final_handler_callback = ::DL.callback("0P") do |context|
          data = API.sqlite3_user_data(context).to_object
          data[:final].call(context)
        end
      end

      data = {
        :cookie => cookie,
        :name => name,
        :func => func,
        :step => step,
        :final => final
      }

      API.sqlite3_create_function(db, name, args, text, data, (func ? @func_handler_callback : nil), (step ? @step_handler_callback : nil), (final ? @final_handler_callback : nil))
    end

    def aggregate_context(context)
      ptr = API.sqlite3_aggregate_context(context, 4)
      ptr.free = nil
      obj = (ptr ? ptr.to_object : nil)
      if obj.nil?
        obj = Hash.new
        ptr.set_object obj
      end
      obj
    end

    def bind_blob(stmt, index, value)
      s = value.to_s
      API.sqlite3_bind_blob(stmt, index, s, s.length, TRANSIENT)
    end

    def bind_text(stmt, index, value, utf16 = false)
      s = value.to_s
      method = (utf16 ? :sqlite3_bind_text16 : :sqlite3_bind_text)
      API.send(method, stmt, index, s, s.length, TRANSIENT)
    end

    def column_text(stmt, column)
      result = API.sqlite3_column_text(stmt, column)
      result ? result.to_s : nil
    end

    def column_name(stmt, column)
      result = API.sqlite3_column_name(stmt, column)
      result ? result.to_s : nil
    end

    def column_decltype(stmt, column)
      result = API.sqlite3_column_decltype(stmt, column)
      result ? result.to_s : nil
    end

    def self.api_delegate(name)
      define_method(name) { |*args| API.send("sqlite3_#{name}", *args) }
    end

    api_delegate :aggregate_count
    api_delegate :bind_double
    api_delegate :bind_int
    api_delegate :bind_int64
    api_delegate :bind_null
    api_delegate :bind_parameter_index
    api_delegate :bind_parameter_name
    api_delegate :busy_timeout
    api_delegate :changes
    api_delegate :close
    api_delegate :column_bytes
    api_delegate :column_bytes16
    api_delegate :column_count
    api_delegate :column_double
    api_delegate :column_int
    api_delegate :column_int64
    api_delegate :column_type
    api_delegate :data_count
    api_delegate :errcode
    api_delegate :finalize
    api_delegate :interrupt
    api_delegate :last_insert_rowid
    api_delegate :libversion
    api_delegate :reset
    api_delegate :result_error
    api_delegate :step
    api_delegate :total_changes
    api_delegate :value_bytes
    api_delegate :value_bytes16
    api_delegate :value_double
    api_delegate :value_int
    api_delegate :value_int64
    api_delegate :value_type

    private

    def utf16_length(ptr)
      len = 0
      loop do
        break if ptr[len,1] == "\0"
        len += 2
      end
      len
    end
  end

end ; end ; end
