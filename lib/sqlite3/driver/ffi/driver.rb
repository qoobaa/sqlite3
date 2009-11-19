require 'sqlite3/driver/ffi/api'

module SQLite3
  module Driver
    module FFI

      class Driver
        TRANSIENT = ::FFI::Pointer.new(-1)

        def open(filename, utf_16 = false)
          handle = ::FFI::MemoryPointer.new(:pointer)
          if utf_16
            filename = filename.encode(Encoding.utf_16native)
            result = API.sqlite3_open16(c_string(filename), handle)
          else
            filename = filename.encode(Encoding.utf_8)
            result = API.sqlite3_open(filename, handle)
          end
          [result, handle.get_pointer(0)]
        end

        def errmsg(db, utf_16 = false)
          if utf_16
            ptr = API.sqlite3_errmsg16(db)
            get_string_utf_16(ptr).force_encoding(Encoding.utf_16native)
          else
            API.sqlite3_errmsg(db).force_encoding(Encoding.utf_8)
          end
        end

        def prepare(db, sql)
          handle = ::FFI::MemoryPointer.new(:pointer)
          remainder = ::FFI::MemoryPointer.new(:pointer)

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

        # def complete?(sql)
        #   API.send(utf16?(string) ? :sqlite3_complete16 : :sqlite3_complete, sql)
        # end

        # def value_blob(value)
        #   blob = API.sqlite3_value_blob(value)
        #   # blob.free = nil
        #   blob.to_s(API.sqlite3_value_bytes(value))
        # end

        # def value_text(value)
        #   method = case utf16
        #            when nil, false
        #              :sqlite3_value_text
        #            when :le
        #              :sqlite3_value_text16le
        #            when :be
        #              :sqlite3_value_text16be
        #            else
        #              :sqlite3_value_text16
        #            end

        #   result = API.send(method, value)

        #   if utf16
        #     # result.free = nil
        #     size = API.sqlite3_value_bytes(value)
        #     result = result.to_s(size)
        #   end

        #   result
        # end

        # def result_text(func, text)
        #   method = case utf16
        #            when false, nil
        #              :sqlite3_result_text
        #            when :le
        #              :sqlite3_result_text16le
        #            when :be
        #              :sqlite3_result_text16be
        #            else
        #              :sqlite3_result_text16
        #            end

        #   s = text.to_s
        #   API.send(method, func, s, s.length, TRANSIENT)
        # end

        # def aggregate_context(context)
        #   ptr = API.sqlite3_aggregate_context(context, 4)
        #   ptr.free = nil
        #   obj = (ptr ? ptr.to_object : nil)
        #   if obj.nil?
        #     obj = Hash.new
        #     ptr.set_object obj
        #   end
        #   obj
        # end

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

        def self.api_delegate(name)
          define_method(name) { |*args| API.send("sqlite3_#{name}", *args) }
        end

        api_delegate :column_name
        api_delegate :column_decltype
        # api_delegate :aggregate_count
        api_delegate :bind_double
        api_delegate :bind_int
        api_delegate :bind_int64
        api_delegate :bind_null
        api_delegate :bind_parameter_index
        api_delegate :bind_parameter_name
        api_delegate :busy_timeout
        # api_delegate :changes
        api_delegate :close
        # api_delegate :column_bytes
        # api_delegate :column_bytes16
        api_delegate :column_count
        api_delegate :column_double
        # api_delegate :column_int
        api_delegate :column_int64
        api_delegate :column_type
        api_delegate :data_count
        api_delegate :errcode
        api_delegate :finalize
        # api_delegate :interrupt
        api_delegate :last_insert_rowid
        # api_delegate :libversion
        # api_delegate :reset
        # api_delegate :result_error
        api_delegate :step
        # api_delegate :total_changes
        # api_delegate :value_bytes
        # api_delegate :value_bytes16
        # api_delegate :value_double
        # api_delegate :value_int
        # api_delegate :value_int64
        # api_delegate :value_type

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
  end
end
