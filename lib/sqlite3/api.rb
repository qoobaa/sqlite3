module SQLite3
  module API
    extend FFI::Library

    lib_paths = Array(ENV["SQLITE3_LIB"] || Dir["/{opt,usr}/{,local/}lib{,64}/libsqlite3.{dylib,so*}"])
    fallback_names = ["libsqlite3", "sqlite3"]
    ffi_lib(lib_paths + fallback_names)

    attach_function :sqlite3_bind_blob, [:pointer, :int, :pointer, :int, :pointer], :int
    attach_function :sqlite3_bind_double, [:pointer, :int, :double], :int
    attach_function :sqlite3_bind_int, [:pointer, :int, :int], :int
    attach_function :sqlite3_bind_int64, [:pointer, :int, :int64], :int
    attach_function :sqlite3_bind_null, [:pointer, :int], :int
    attach_function :sqlite3_bind_parameter_index, [:pointer, :string], :int
    attach_function :sqlite3_bind_text, [:pointer, :int, :string, :int, :pointer], :int
    attach_function :sqlite3_bind_text16, [:pointer, :int, :pointer, :int, :pointer], :int
    attach_function :sqlite3_busy_timeout, [:pointer, :int], :int
    attach_function :sqlite3_changes, [:pointer], :int
    attach_function :sqlite3_close, [:pointer], :int
    attach_function :sqlite3_column_blob, [:pointer, :int], :pointer
    attach_function :sqlite3_column_bytes, [:pointer, :int], :int
    attach_function :sqlite3_column_bytes16, [:pointer, :int], :int
    attach_function :sqlite3_column_count, [:pointer], :int
    attach_function :sqlite3_column_decltype, [:pointer, :int], :string
    attach_function :sqlite3_column_double, [:pointer, :int], :double
    attach_function :sqlite3_column_int64, [:pointer, :int], :int64
    attach_function :sqlite3_column_name, [:pointer, :int], :string
    attach_function :sqlite3_column_text, [:pointer, :int], :string
    attach_function :sqlite3_column_text16, [:pointer, :int], :pointer
    attach_function :sqlite3_column_type, [:pointer, :int], :int
    attach_function :sqlite3_data_count, [:pointer], :int
    attach_function :sqlite3_errcode, [:pointer], :int
    attach_function :sqlite3_errmsg, [:pointer], :string
    attach_function :sqlite3_errmsg16, [:pointer], :pointer
    attach_function :sqlite3_finalize, [:pointer], :int
    attach_function :sqlite3_last_insert_rowid, [:pointer], :int64
    attach_function :sqlite3_libversion, [], :string
    attach_function :sqlite3_open, [:string, :pointer], :int
    attach_function :sqlite3_open16, [:pointer, :pointer], :int
    attach_function :sqlite3_prepare, [:pointer, :string, :int, :pointer, :pointer], :int
    attach_function :sqlite3_reset, [:pointer], :int
    attach_function :sqlite3_step, [:pointer], :int
  end
end
