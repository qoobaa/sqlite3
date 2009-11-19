module SQLite3
  module Driver
    module FFI

      module API
        extend ::FFI::Library

        ffi_lib case RUBY_PLATFORM.downcase
                when /darwin/
                  "libsqlite3.dylib"
                when /linux|freebsd|netbsd|openbsd|dragonfly|solaris/
                  "libsqlite3.so"
                when /win32/
                  "sqlite3.dll"
                else
                  abort <<-EOF
==== UNSUPPORTED PLATFORM ======================================================
The platform '#{RUBY_PLATFORM}' is unsupported. Please help the author by
editing the following file to allow your sqlite3 library to be found, and
submitting a patch to qoobaa@gmail.com. Thanks!

#{__FILE__}
================================================================================
        EOF
                end

        attach_function :sqlite3_libversion, [], :string
        attach_function :sqlite3_open, [:string, :pointer], :int
        attach_function :sqlite3_open16, [:pointer, :pointer], :int
        attach_function :sqlite3_close, [:pointer], :int
        attach_function :sqlite3_errmsg, [:pointer], :string
        attach_function :sqlite3_errmsg16, [:pointer], :pointer
        attach_function :sqlite3_errcode, [:pointer], :int
        attach_function :sqlite3_prepare, [:pointer, :string, :int, :pointer, :pointer], :int
        # attach_function :sqlite3_prepare16, [:pointer, :pointer, :int, :pointer, :pointer], :int
        attach_function :sqlite3_finalize, [:pointer], :int
        # attach_function :sqlite3_reset, [:pointer], :int
        attach_function :sqlite3_step, [:pointer], :int
        attach_function :sqlite3_last_insert_rowid, [:pointer], :int64
        # attach_function :sqlite3_changes, [:pointer], :int
        # attach_function :sqlite3_total_changes, [:pointer], :int
        # attach_function :sqlite3_interrupt, [:pointer], :void
        # attach_function :sqlite3_complete, [:string], :int
        # attach_function :sqlite3_complete16, [:pointer], :int
        attach_function :sqlite3_busy_timeout, [:pointer, :int], :int
        attach_function :sqlite3_bind_blob, [:pointer, :int, :pointer, :int, :pointer], :int
        attach_function :sqlite3_bind_double, [:pointer, :int, :double], :int
        attach_function :sqlite3_bind_int, [:pointer, :int, :int], :int
        attach_function :sqlite3_bind_int64, [:pointer, :int, :int64], :int
        attach_function :sqlite3_bind_null, [:pointer, :int], :int
        attach_function :sqlite3_bind_text, [:pointer, :int, :string, :int, :pointer], :int
        attach_function :sqlite3_bind_text16, [:pointer, :int, :pointer, :int, :pointer], :int
        # attach_function :sqlite3_bind_value, [:pointer, :int, :pointer], :int
        # attach_function :sqlite3_bind_parameter_count, [:pointer], :int
        # attach_function :sqlite3_bind_parameter_name, [:pointer, :int], :string
        # attach_function :sqlite3_bind_parameter_index, [:pointer, :string], :int
        attach_function :sqlite3_column_count, [:pointer], :int
        attach_function :sqlite3_data_count, [:pointer], :int
        attach_function :sqlite3_column_blob, [:pointer, :int], :pointer
        attach_function :sqlite3_column_bytes, [:pointer, :int], :int
        attach_function :sqlite3_column_bytes16, [:pointer, :int], :int
        attach_function :sqlite3_column_decltype, [:pointer, :int], :string
        # attach_function :sqlite3_column_decltype16, [:pointer, :int], :pointer
        attach_function :sqlite3_column_double, [:pointer, :int], :double
        # attach_function :sqlite3_column_int, [:pointer, :int], :int
        attach_function :sqlite3_column_int64, [:pointer, :int], :int64
        attach_function :sqlite3_column_name, [:pointer, :int], :string
        # attach_function :sqlite3_column_name16, [:pointer, :int], :pointer
        attach_function :sqlite3_column_text, [:pointer, :int], :string
        attach_function :sqlite3_column_text16, [:pointer, :int], :pointer
        attach_function :sqlite3_column_type, [:pointer, :int], :int
        # attach_function :sqlite3_aggregate_count, [:pointer], :int
        # attach_function :sqlite3_value_blob, [:pointer], :pointer
        # attach_function :sqlite3_value_bytes, [:pointer], :int
        # attach_function :sqlite3_value_bytes16, [:pointer], :int
        # attach_function :sqlite3_value_double, [:pointer], :double
        # attach_function :sqlite3_value_int, [:pointer], :int
        # attach_function :sqlite3_value_int64, [:pointer], :int64
        # attach_function :sqlite3_value_text, [:pointer], :string
        # attach_function :sqlite3_value_text16, [:pointer], :pointer
        # attach_function :sqlite3_value_text16le, [:pointer], :pointer
        # attach_function :sqlite3_value_text16be, [:pointer], :pointer
        # attach_function :sqlite3_value_type, [:pointer], :int
        # attach_function :sqlite3_aggregate_context, [:pointer, :int], :pointer
        # attach_function :sqlite3_user_data, [:pointer], :pointer
        # attach_function :sqlite3_get_auxdata, [:pointer, :int], :pointer
        # attach_function :sqlite3_set_auxdata, [:pointer, :int, :pointer, :pointer], :void
        # attach_function :sqlite3_result_blob, [:pointer, :pointer, :int, :pointer], :void
        # attach_function :sqlite3_result_double, [:pointer, :double], :void
        # attach_function :sqlite3_result_error, [:pointer, :string, :int], :void
        # attach_function :sqlite3_result_error16, [:pointer, :pointer, :int], :void
        # attach_function :sqlite3_result_int, [:pointer, :int], :void
        # attach_function :sqlite3_result_int64, [:pointer, :int64], :void
        # attach_function :sqlite3_result_null, [:pointer], :void
        # attach_function :sqlite3_result_text, [:pointer, :string, :int, :pointer], :void
        # attach_function :sqlite3_result_text16, [:pointer, :pointer, :int, :pointer], :void
        # attach_function :sqlite3_result_text16le, [:pointer, :pointer, :int, :pointer], :void
        # attach_function :sqlite3_result_text16be, [:pointer, :pointer, :int, :pointer], :void
        # attach_function :sqlite3_result_value, [:pointer, :pointer], :void
        # attach_function :sqlite3_create_collation, [:pointer, :string, :int, :pointer, :pointer], :int
        # attach_function :sqlite3_create_collation16, [:pointer, :string, :int, :pointer, :pointer], :int
        # attach_function :sqlite3_collation_needed, [:pointer, :pointer, :pointer], :int
        # attach_function :sqlite3_collation_needed16, [:pointer, :pointer, :pointer], :int
      end

    end
  end
end
