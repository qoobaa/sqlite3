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
end
