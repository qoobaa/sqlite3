require "helper"

class TestDatabaseQueries < Test::Unit::TestCase
  def setup
    @db = SQLite3::Database.new(":memory:")
    @db.execute("CREATE TABLE t1(id INTEGER PRIMARY KEY ASC, t TEXT, nu1 NUMERIC, i1 INTEGER, i2 INTEGER, no BLOB)")
  end

  def teardown
    @db.close
  end

  def test_tables_empty
    assert_equal [], @db.execute("SELECT * FROM t1")
  end

  def test_execute
    @db.execute("INSERT INTO t1 VALUES(NULL, 'text1', 1.22, 42, 4294967296, NULL)")
    rows = @db.execute("SELECT * FROM t1")
    assert_equal 1, rows.size
    row = rows[0]
    assert_equal "text1", row[1]
    assert_equal "1.22", row[2]
    assert_equal "42", row[3]
    assert_equal "4294967296", row[4]
    assert_nil row[5]
  end

  def test_execute_with_bindings
    blob = open("test/fixtures/SQLite.gif", "rb").read
    @db.execute("INSERT INTO t1 VALUES(?, ?, ?, ?, ?, ?)", nil, "text1", 1.22, 42, 4294967296, blob)
    rows = @db.execute("SELECT * FROM t1")
    assert_equal 1, rows.size
    row = rows[0]
    assert_equal "text1", row[1]
    assert_equal "1.22", row[2]
    assert_equal "42", row[3]
    assert_equal "4294967296", row[4]
    assert_equal blob, row[5]
  end

  def test_execute_with_different_encodings
    expected_string = "text1"
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::ASCII_8BIT))
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_8))
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_16LE))
    @db.execute("INSERT INTO t1 VALUES(NULL, ?, NULL, NULL, NULL, NULL)", expected_string.encode(Encoding::UTF_16BE))
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

  def test_last_insert_row_id
    @db.execute("INSERT INTO t1 VALUES(NULL, NULL, NULL, NULL, NULL, NULL)")
    id = @db.last_insert_row_id
    rows = @db.execute("SELECT * FROM t1 WHERE id = #{id}")
    assert_equal 1, rows.size
  end

  # def test_execute_with_closed_database
  #   @db.close
  #   @db.execute("SELECT * FROM t1")
  # end
end
