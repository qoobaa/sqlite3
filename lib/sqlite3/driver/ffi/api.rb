require "ffi"

module SQLite3
  module Driver
    module FFI

      module API

        extend ::FFI::Library

        ffi_lib "libsqlite3.so"

        # extern "const char *sqlite3_libversion()"
        attach_function :sqlite3_libversion, [], :string

        # extern "int sqlite3_open(const char*,db*)"
        attach_function :sqlite3_open, [:string, :pointer], :int

        # extern "int sqlite3_open16(const void*,db*)"
        attach_function :sqlite3_open16, [:pointer, :pointer], :int

        # extern "int sqlite3_close(db)"
        attach_function :sqlite3_close, [:pointer], :int

        # extern "const char* sqlite3_errmsg(db)"
        attach_function :sqlite3_errmsg, [:pointer], :string

        # extern "void* sqlite3_errmsg16(db)"
        attach_function :sqlite3_errmsg16, [:pointer], :pointer

        # extern "int sqlite3_errcode(db)"
        attach_function :sqlite3_errcode, [:pointer], :int

        # extern "int sqlite3_prepare(db,const char*,int,stmt*,const char**)"
        attach_function :sqlite3_prepare, [:pointer, :string, :int, :pointer, :pointer], :int

        # extern "int sqlite3_prepare16(db,const void*,int,stmt*,const void**)"
        attach_function :sqlite3_prepare16, [:pointer, :pointer, :int, :pointer, :pointer], :int

        # extern "int sqlite3_finalize(stmt)"
        attach_function :sqlite3_finalize, [:pointer], :int

        # extern "int sqlite3_reset(stmt)"
        attach_function :sqlite3_reset, [:pointer], :int

        # extern "int sqlite3_step(stmt)"
        attach_function :sqlite3_step, [:pointer], :int

        # extern "int64 sqlite3_last_insert_rowid(db)"
        attach_function :sqlite3_last_insert_rowid, [:pointer], :int64

        # extern "int sqlite3_changes(db)"
        attach_function :sqlite3_changes, [:pointer], :int

        # extern "int sqlite3_total_changes(db)"
        attach_function :sqlite3_total_changes, [:pointer], :int

        # extern "void sqlite3_interrupt(db)"
        attach_function :sqlite3_interrupt, [:pointer], :void

        # extern "ibool sqlite3_complete(const char*)"
        attach_function :sqlite3_complete, [:string], :int

        # extern "ibool sqlite3_complete16(const void*)"
        attach_function :sqlite3_complete16, [:pointer], :int

        # extern "int sqlite3_busy_handler(db,void*,void*)"
        attach_function :sqlite3_busy_handler, [:pointer, :pointer, :pointer], :int

        # extern "int sqlite3_busy_timeout(db,int)"
        attach_function :sqlite3_busy_timeout, [:pointer, :int], :int

        # extern "int sqlite3_set_authorizer(db,void*,void*)"
        attach_function :sqlite3_set_authorizer, [:pointer, :pointer, :pointer], :int

        # extern "void* sqlite3_trace(db,void*,void*)"
        attach_function :sqlite3_trace, [:pointer, :pointer, :pointer], :pointer

        # extern "int sqlite3_bind_blob(stmt,int,const void*,int,void*)"
        attach_function :sqlite3_bind_blob, [:pointer, :int, :pointer, :int, :pointer], :int

        # extern "int sqlite3_bind_double(stmt,int,double)"
        attach_function :sqlite3_bind_double, [:pointer, :int, :double], :int

        # extern "int sqlite3_bind_int(stmt,int,int)"
        attach_function :sqlite3_bind_int, [:pointer, :int, :int], :int

        # extern "int sqlite3_bind_int64(stmt,int,int64)"
        attach_function :sqlite3_bind_int64, [:pointer, :int, :int64], :int

        # extern "int sqlite3_bind_null(stmt,int)"
        attach_function :sqlite3_bind_null, [:pointer, :int], :int

        # extern "int sqlite3_bind_text(stmt,int,const char*,int,void*)"
        attach_function :sqlite3_bind_text, [:pointer, :int, :string, :int, :pointer], :int

        # extern "int sqlite3_bind_text16(stmt,int,const void*,int,void*)"
        attach_function :sqlite3_bind_text16, [:pointer, :int, :pointer, :int, :pointer], :int

        # #extern "int sqlite3_bind_value(stmt,int,value)"
        attach_function :sqlite3_bind_value, [:pointer, :int, :pointer], :int

        # extern "int sqlite3_bind_parameter_count(stmt)"
        attach_function :sqlite3_bind_parameter_count, [:pointer], :int

        # extern "const char* sqlite3_bind_parameter_name(stmt,int)"
        attach_function :sqlite3_bind_parameter_name, [:pointer, :int], :string

        # extern "int sqlite3_bind_parameter_index(stmt,const char*)"
        attach_function :sqlite3_bind_parameter_index, [:pointer, :string], :int

        # extern "int sqlite3_column_count(stmt)"
        attach_function :sqlite3_column_count, [:pointer], :int

        # extern "int sqlite3_data_count(stmt)"
        attach_function :sqlite3_data_count, [:pointer], :int

        # extern "const void *sqlite3_column_blob(stmt,int)"
        attach_function :sqlite3_column_blob, [:pointer, :int], :pointer

        # extern "int sqlite3_column_bytes(stmt,int)"
        attach_function :sqlite3_column_bytes, [:pointer, :int], :int

        # extern "int sqlite3_column_bytes16(stmt,int)"
        attach_function :sqlite3_column_bytes16, [:pointer, :int], :int

        # extern "const char *sqlite3_column_decltype(stmt,int)"
        attach_function :sqlite3_column_decltype, [:pointer, :int], :string

        # extern "void *sqlite3_column_decltype16(stmt,int)"
        attach_function :sqlite3_column_decltype16, [:pointer, :int], :pointer

        # extern "double sqlite3_column_double(stmt,int)"
        attach_function :sqlite3_column_double, [:pointer, :int], :double

        # extern "int sqlite3_column_int(stmt,int)"
        attach_function :sqlite3_column_int, [:pointer, :int], :int

        # extern "int64 sqlite3_column_int64(stmt,int)"
        attach_function :sqlite3_column_int64, [:pointer, :int], :int64

        # extern "const char *sqlite3_column_name(stmt,int)"
        attach_function :sqlite3_column_name, [:pointer, :int], :string

        # extern "const void *sqlite3_column_name16(stmt,int)"
        attach_function :sqlite3_column_name16, [:pointer, :int], :pointer

        # extern "const char *sqlite3_column_text(stmt,int)"
        attach_function :sqlite3_column_text, [:pointer, :int], :string

        # extern "const void *sqlite3_column_text16(stmt,int)"
        attach_function :sqlite3_column_text16, [:pointer, :int], :pointer

        # extern "int sqlite3_column_type(stmt,int)"
        attach_function :sqlite3_column_type, [:pointer, :int], :int

        # extern "int sqlite3_create_function(db,const char*,int,int,void*,void*,void*,void*)"
        attach_function :sqlite3_create_function, [:pointer, :string, :int, :int, :pointer, :pointer, :pointer, :pointer], :int

        # extern "int sqlite3_create_function16(db,const void*,int,int,void*,void*,void*,void*)"
        attach_function :sqlite3_create_function16, [:pointer, :pointer, :int, :int, :pointer, :pointer, :pointer, :pointer], :int

        # extern "int sqlite3_aggregate_count(context)"
        attach_function :sqlite3_aggregate_count, [:pointer], :int

        # extern "const void *sqlite3_value_blob(value)"
        attach_function :sqlite3_value_blob, [:pointer], :pointer

        # extern "int sqlite3_value_bytes(value)"
        attach_function :sqlite3_value_bytes, [:pointer], :int

        # extern "int sqlite3_value_bytes16(value)"
        attach_function :sqlite3_value_bytes16, [:pointer], :int

        # extern "double sqlite3_value_double(value)"
        attach_function :sqlite3_value_double, [:pointer], :double

        # extern "int sqlite3_value_int(value)"
        attach_function :sqlite3_value_int, [:pointer], :int

        # extern "int64 sqlite3_value_int64(value)"
        attach_function :sqlite3_value_int64, [:pointer], :int64

        # extern "const char* sqlite3_value_text(value)"
        attach_function :sqlite3_value_text, [:pointer], :string

        # extern "const void* sqlite3_value_text16(value)"
        attach_function :sqlite3_value_text16, [:pointer], :pointer

        # extern "const void* sqlite3_value_text16le(value)"
        attach_function :sqlite3_value_text16le, [:pointer], :pointer

        # extern "const void* sqlite3_value_text16be(value)"
        attach_function :sqlite3_value_text16be, [:pointer], :pointer

        # extern "int sqlite3_value_type(value)"
        attach_function :sqlite3_value_type, [:pointer], :int

        # extern "void *sqlite3_aggregate_context(context,int)"
        attach_function :sqlite3_aggregate_context, [:pointer, :int], :pointer

        # extern "void *sqlite3_user_data(context)"
        attach_function :sqlite3_user_data, [:pointer], :pointer

        # extern "void *sqlite3_get_auxdata(context,int)"
        attach_function :sqlite3_get_auxdata, [:pointer, :int], :pointer

        # extern "void sqlite3_set_auxdata(context,int,void*,void*)"
        attach_function :sqlite3_set_auxdata, [:pointer, :int, :pointer, :pointer], :void

        # extern "void sqlite3_result_blob(context,const void*,int,void*)"
        attach_function :sqlite3_result_blob, [:pointer, :pointer, :int, :pointer], :void

        # extern "void sqlite3_result_double(context,double)"
        attach_function :sqlite3_result_double, [:pointer, :double], :void

        # extern "void sqlite3_result_error(context,const char*,int)"
        attach_function :sqlite3_result_error, [:pointer, :string, :int], :void

        # extern "void sqlite3_result_error16(context,const void*,int)"
        attach_function :sqlite3_result_error16, [:pointer, :pointer, :int], :void

        # extern "void sqlite3_result_int(context,int)"
        attach_function :sqlite3_result_int, [:pointer, :int], :void

        # extern "void sqlite3_result_int64(context,int64)"
        attach_function :sqlite3_result_int64, [:pointer, :int64], :void

        # extern "void sqlite3_result_null(context)"
        attach_function :sqlite3_result_null, [:pointer], :void

        # extern "void sqlite3_result_text(context,const char*,int,void*)"
        attach_function :sqlite3_result_text, [:pointer, :string, :int, :pointer], :void

        # extern "void sqlite3_result_text16(context,const void*,int,void*)"
        attach_function :sqlite3_result_text16, [:pointer, :pointer, :int, :pointer], :void

        # extern "void sqlite3_result_text16le(context,const void*,int,void*)"
        attach_function :sqlite3_result_text16le, [:pointer, :pointer, :int, :pointer], :void

        # extern "void sqlite3_result_text16be(context,const void*,int,void*)"
        attach_function :sqlite3_result_text16be, [:pointer, :pointer, :int, :pointer], :void

        # extern "void sqlite3_result_value(context,value)"
        attach_function :sqlite3_result_value, [:pointer, :pointer], :void

        # extern "int sqlite3_create_collation(db,const char*,int,void*,void*)"
        attach_function :sqlite3_create_collation, [:pointer, :string, :int, :pointer, :pointer], :int

        # extern "int sqlite3_create_collation16(db,const char*,int,void*,void*)"
        attach_function :sqlite3_create_collation16, [:pointer, :string, :int, :pointer, :pointer], :int

        # extern "int sqlite3_collation_needed(db,void*,void*)"
        attach_function :sqlite3_collation_needed, [:pointer, :pointer, :pointer], :int

        # extern "int sqlite3_collation_needed16(db,void*,void*)"
        attach_function :sqlite3_collation_needed16, [:pointer, :pointer, :pointer], :int
      end

    end
  end
end
