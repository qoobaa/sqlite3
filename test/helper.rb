require "rubygems"
gem "test-unit"
require "test/unit"

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require "sqlite3"

class Test::Unit::TestCase
  def fixture(filename)
    File.join(File.dirname(__FILE__), "fixtures", filename)
  end
end
