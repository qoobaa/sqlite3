require 'sqlite3/driver/ffi/api'

module SQLite3
  module Driver
    module FFI

      class Driver
        TRANSIENT = ::FFI::Pointer.new(-1)

        def open(filename)
          handle = ::FFI::MemoryPointer.new(:pointer)
          result = API.sqlite3_open(filename, handle)
          [result, handle.get_pointer(0)]
        end

        def open16(filename)
          handle = ::FFI::MemoryPointer.new(:pointer)
          filename = filename.encode(Encoding.native_utf_16)
          result = API.sqlite3_open16(c_string(filename), handle)
          [result, handle.get_pointer(0)]
        end

        def errmsg(db)
          API.sqlite3_errmsg(db).force_encoding(::Encoding::UTF_8)
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

        def column_blob(stmt, column)
          blob = API.sqlite3_column_blob(stmt, column)
          length = API.sqlite3_column_bytes(stmt, column)
          blob.get_bytes(0, length)
          # blob.free = nil
          # blob.to_s(API.sqlite3_column_bytes(stmt, column))
        end

        def result_text(func, text)
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
          when ::Encoding::UTF_8, ::Encoding::US_ASCII
            method = :sqlite3_bind_text
          when ::Encoding::UTF_16LE, ::Encoding::UTF_16BE
            value = add_byte_order_mask(value)
            method = :sqlite3_bind_text16
          else
            method = :sqlite3_bind_blob
          end
          API.send(method, stmt, index, value, value.bytesize, TRANSIENT)
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

        # api_delegate :aggregate_count
        api_delegate :bind_double
        api_delegate :bind_int
        api_delegate :bind_int64
        api_delegate :bind_null
        api_delegate :bind_parameter_index
        api_delegate :bind_parameter_name
        # api_delegate :busy_timeout
        # api_delegate :changes
        api_delegate :close
        # api_delegate :column_bytes
        # api_delegate :column_bytes16
        api_delegate :column_count
        # api_delegate :column_double
        # api_delegate :column_int
        # api_delegate :column_int64
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
          len = 0
          len += 2 until ptr.get_bytes(len, 2) == "\0\0"
          ptr.get_bytes(0, len)
        end
      end
    end
  end
end
