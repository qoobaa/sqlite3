require "helper"

class TestDatabaseInitialization < Test::Unit::TestCase
  def setup
    @db_filename = "test_database.db"
    File.delete(@db_filename) if File.exists?(@db_filename)
    @db = SQLite3::Database.new(@db_filename)
  end

  def teardown
    File.delete(@db_filename) if File.exists?(@db_filename)
  end

  def test_database_file_exists
    assert File.exists?(@db_filename)
  end

  def test_database_opened
    assert_false @db.closed?
  end

  def test_database_closing
    @db.close
    assert @db.closed?
  end

  def test_encoding_conversion_from_utf_16_to_utf_8
    expected_string = "test"
    db_filename = "test_database_encoding.db"
    File.delete(db_filename) if File.exists?(db_filename)
    db = SQLite3::Database.new(db_filename, :encoding => "utf-16le")
    db.execute("CREATE TABLE t1(t TEXT)")
    db.execute("INSERT INTO t1 VALUES (?)", expected_string.encode(Encoding::UTF_8))
    db.execute("INSERT INTO t1 VALUES (?)", expected_string.encode(Encoding::UTF_16LE))
    rows = db.execute("SELECT * FROM t1")
    assert_equal 2, rows.size
    assert_equal expected_string.encode(Encoding::UTF_16LE), rows[0][0]
    assert_equal Encoding::UTF_16LE, rows[0][0].encoding
    assert_equal expected_string.encode(Encoding::UTF_16LE), rows[1][0]
    assert_equal Encoding::UTF_16LE, rows[1][0].encoding
    db.close
    db = SQLite3::Database.new(db_filename)
    rows = db.execute("SELECT * FROM t1")
    assert_equal 2, rows.size
    assert_equal expected_string, rows[0][0]
    assert_equal Encoding::UTF_8, rows[0][0].encoding
    assert_equal expected_string, rows[1][0]
    assert_equal Encoding::UTF_8, rows[1][0].encoding
    File.delete(db_filename) if File.exists?(db_filename)
  end
end
