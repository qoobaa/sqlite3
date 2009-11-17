require "helper"

class TestDatabaseQueries < Test::Unit::TestCase
  def setup
    @db = SQLite3::Database.new(":memory:")
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
    @db.execute("INSERT INTO t1 VALUES(?, ?, ?, ?, ?)", nil, "text1", 1.22, 42, nil)
    rows = @db.execute("SELECT * FROM t1")
    assert_equal 1, rows.size
    row = rows[0]
    assert_equal "text1", row[1]
    assert_equal "1.22", row[2]
    assert_equal "42", row[3]
    assert_nil row[4]
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

  def test_trace
    @db.trace { |data, sql| puts data, sql }
    rows = @db.execute("SELECT * FROM t1")
  end
end
