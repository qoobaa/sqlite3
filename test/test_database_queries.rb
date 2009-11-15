require "helper"

class TestDatabaseQueries < Test::Unit::TestCase
  def setup
    @db_filename = "test_database.db"
    File.delete(@db_filename) if File.exists?(@db_filename)
    @db = SQLite3::Database.new(@db_filename)
    @db.execute_batch <<eos
CREATE TABLE t1(id INTEGER PRIMARY KEY ASC, t TEXT, nu NUMERIC, i INTEGER, no BLOB);
CREATE TABLE t2(id INTEGER PRIMARY KEY ASC, t TEXT, nu NUMERIC, i INTEGER, no BLOB);
eos
  end

  def teardown
    File.delete(@db_filename) if File.exists?(@db_filename)
  end

  def test_tables_empty
    assert_equal [], @db.execute("SELECT * FROM t1")
    assert_equal [], @db.execute("SELECT * FROM t2")
  end

  def test_insert_and_select
    @db.execute("INSERT INTO t1 VALUES(NULL, 'text1', 1.22, 42, NULL)")
    rows = @db.execute("SELECT * FROM t1")
    assert_equal 1, rows.size
    row = rows[0]
    assert_equal "text1", row[1]
    assert_equal "1.22", row[2]
    assert_equal "42", row[3]
    assert_nil row[4]
  end
end
