require "helper"

class TestStatement < Test::Unit::TestCase
  def setup
    @db = SQLite3::Database.new(":memory:")
    @db.execute("CREATE TABLE t1(id INTEGER PRIMARY KEY ASC, t TEXT, nu1 NUMERIC, i1 INTEGER, i2 INTEGER, no BLOB)")
    @statement = @db.prepare("INSERT INTO t1 VALUES(:ID, :T, :NU1, :I1, :I2, :NO)")
  end

  def teardown
    @statement.close
    @db.close
  end

  test "bind param by name" do
    @statement.bind_param("T", "test")
  end


  test "bind param by name with colon" do
    @statement.bind_param(":T", "test")
  end

  test "bind param by number" do
    @statement.bind_param(1, "test")
  end

  test "bind non existing param name" do
    assert_raises(SQLite3::Exception) { @statement.bind_param(":NONEXISTING", "test") }
  end

  test "execute statement" do
    @statement.execute
  end

  test "execute statement multiple times" do
    @statement.bind_param("T", "test")
    @statement.execute
    @statement.bind_param("NU1", 500)
    @statement.execute
  end
end
