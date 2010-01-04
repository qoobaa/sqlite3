require "helper"
require "active_record"

class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.integer :login_count
      t.binary :avatar
      t.float :ranking
      t.date :birthdate
      t.boolean :active
      t.datetime :expires_at
      t.text :about_me
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end

class User < ActiveRecord::Base

end

class TestActiveRecord < Test::Unit::TestCase
  def setup
    ActiveRecord::Base.establish_connection(:adapter  => "sqlite3", :database => ":memory:")
    ActiveRecord::Base.default_timezone = :utc
    ActiveRecord::Migration.verbose = false
    CreateUsers.migrate(:up)
  end

  def test_user_count
    assert_equal 0, User.count
  end

  def test_user_columns
    column_names = User.column_names
    assert column_names.include?("id")
    assert column_names.include?("login")
    assert column_names.include?("login_count")
    assert column_names.include?("avatar")
    assert column_names.include?("ranking")
    assert column_names.include?("birthdate")
    assert column_names.include?("active")
    assert column_names.include?("expires_at")
    assert column_names.include?("about_me")
    assert column_names.include?("created_at")
    assert column_names.include?("updated_at")
  end

  def test_user_create
    login = "bob"
    avatar = open("test/fixtures/SQLite.gif", "rb").read
    login_count = 0
    ranking = 1.0
    active = true
    birthdate = Date.new(1969, 12, 1)
    expires_at = DateTime.new(2100, 12, 1, 12, 54, 22)
    about_me = "aboutme" * 500

    User.create!(:login => login,
                 :login_count => login_count,
                 :avatar => avatar,
                 :ranking => ranking,
                 :active => active,
                 :birthdate => birthdate,
                 :expires_at => expires_at,
                 :about_me => about_me)

    user = User.first

    assert_equal login, user.login
    assert_equal login_count, user.login_count
    assert_equal avatar, user.avatar
    assert_equal ranking, user.ranking
    assert_equal active, user.active
    assert_equal birthdate, user.birthdate
    assert_equal expires_at, user.expires_at
    assert_equal about_me, user.about_me
  end

  def test_user_update
    User.create!(:login => "bob")
    user = User.first
    assert_equal "bob", user.login
    user.update_attributes(:login => "alice")
    user = User.first
    assert_equal "alice", user.login
  end

  def test_user_delete
    User.create!(:login => "bob")
    user = User.first
    assert_equal "bob", user.login
    user.destroy
    assert_equal 0, User.count
  end

  def test_user_dirty_attributes
    User.create!(:login => "bob")
    user = User.first
    assert_equal "bob", user.login
    user.login = "alice"
    assert user.login_changed?
    assert_equal "alice", user.login
    assert_equal "bob", user.login_was
  end

  def test_transaction_commit
    User.transaction do
      User.create!
    end
    assert_equal 1, User.count
  end

  def test_transaction_rollback
    User.transaction do
      User.create!
      raise ActiveRecord::Rollback
    end
    assert_equal 0, User.count
  end

  def test_reload
    User.create!(:login => "bob")
    user = User.first
    assert_equal "bob", user.login
    user.login = "alice"
    assert_equal "alice", user.login
    user.reload
    assert_equal "bob", user.login
  end

  def test_save
    user = User.new(:login => "alice")
    user.save
    assert_equal 1, User.count
  end

  def test_save_with_bang
    user = User.new(:login => "alice")
    user.save!
    assert_equal 1, User.count
  end
end
