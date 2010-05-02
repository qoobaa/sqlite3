module SQLite3
  class Driver
    TRANSIENT = FFI::Pointer.new(-1)

    def open(filename, utf_16 = false)
      handle = FFI::MemoryPointer.new(:pointer)
      if utf_16
        filename = filename.encode(Encoding.utf_16native) if filename.respond_to?(:encode)
        result = API.sqlite3_open16(c_string(filename), handle)
      else
        filename = filename.encode(Encoding.utf_8) if filename.respond_to?(:encode)
        result = API.sqlite3_open(filename, handle)
      end
      [result, handle.get_pointer(0)]
    end

    def errmsg(db, utf_16 = false)
      if utf_16
        ptr = API.sqlite3_errmsg16(db)
        result = get_string_utf_16(ptr)
        result.force_encoding(Encoding.utf_16native) if result.respond_to?(:force_encoding)
        result
      else
        result = API.sqlite3_errmsg(db)
        result.force_encoding(Encoding.utf_8) if result.respond_to?(:force_encoding)
        result
      end
    end

    def prepare(db, sql)
      handle = FFI::MemoryPointer.new(:pointer)
      remainder = FFI::MemoryPointer.new(:pointer)

      if Encoding.utf_16?(sql)
        str = c_string(sql)
        result = API.sqlite3_prepare16(db, str, str.bytesize, handle, remainder)
        remainder_string = get_string_utf_16(remainder.get_pointer(0))
      else
        result = API.sqlite3_prepare(db, sql, sql.bytesize, handle, remainder)
        remainder_string = remainder.get_pointer(0).get_string(0)
      end

      [result, handle.get_pointer(0), remainder_string]
    end

    def bind_string(stmt, index, value)
      case value.encoding
      when Encoding.utf_8, Encoding.us_ascii
        API.sqlite3_bind_text(stmt, index, value, value.bytesize, TRANSIENT)
      when Encoding.utf_16le, Encoding.utf_16be
        value = add_byte_order_mask(value)
        API.sqlite3_bind_text16(stmt, index, value, value.bytesize, TRANSIENT)
      else
        API.sqlite3_bind_blob(stmt, index, value, value.bytesize, TRANSIENT)
      end
    end

    def column_blob(stmt, column)
      blob = API.sqlite3_column_blob(stmt, column)
      length = API.sqlite3_column_bytes(stmt, column)
      blob.get_bytes(0, length) # free?
    end

    def column_text(stmt, column, utf_16 = false)
      if utf_16
        ptr = API.sqlite3_column_text16(stmt, column)
        length = API.sqlite3_column_bytes16(stmt, column)
        ptr.get_bytes(0, length).force_encoding(Encoding.utf_16native) # free?
      else
        API.sqlite3_column_text(stmt, column).force_encoding(Encoding.utf_8)
      end
    end

    def extension_support?
      API::EXTENSION_SUPPORT
    end

    def load_extension(db, name, entry_point = nil)
      result = API.sqlite3_load_extension(db, name, entry_point, nil)
      [result, nil]
    end

    def enable_load_extension(db, onoff = false)
      API.sqlite3_enable_load_extension(db, (onoff ? 1 : 0))
    end

    def self.api_delegate(name)
      define_method(name) { |*args| API.send("sqlite3_#{name}", *args) }
    end

    api_delegate :bind_double
    api_delegate :bind_int
    api_delegate :bind_int64
    api_delegate :bind_null
    api_delegate :bind_parameter_index
    api_delegate :busy_timeout
    api_delegate :changes
    api_delegate :close
    api_delegate :column_count
    api_delegate :column_decltype
    api_delegate :column_double
    api_delegate :column_int64
    api_delegate :column_name
    api_delegate :column_type
    api_delegate :data_count
    api_delegate :errcode
    api_delegate :finalize
    api_delegate :last_insert_rowid
    api_delegate :libversion
    api_delegate :reset
    api_delegate :step

    private

    def c_string(string)
      if Encoding.utf_16?(string)
        result = add_byte_order_mask(string)
        terminate_string!(result)
      else
        string # FFI does the job
      end
    end

    def add_byte_order_mask(string)
      "\uFEFF".encode(string.encoding) + string
    end

    def terminate_string!(string)
      string << "\0\0".force_encoding(string.encoding)
    end

    def get_string_utf_16(ptr)
      length = 0
      length += 2 until ptr.get_bytes(length, 2) == "\0\0"
      ptr.get_bytes(0, length)
    end
  end
end
