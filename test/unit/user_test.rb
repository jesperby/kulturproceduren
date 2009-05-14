require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "successful authentication" do
    u = User.authenticate("foo", "foopass")

    assert_not_nil u
    assert_equal u.username, "foo"
  end

  test "invalid password" do
    u = User.authenticate("foo", "fail")
    assert_nil u
  end

  test "invalid username" do
    u = User.authenticate("notexist", "notexist")
    assert_nil u
  end


  test "password creation" do
    pass = "passcreatepass"
    u = User.new
    u.username = "passcreateuser"
    u.password = pass
    u.save

    u2 = User.authenticate(u.username, pass)

    assert_not_nil u2
    assert_equal u2.username, u.username
  end

  test "unique username" do
    u = User.new
    u.username = "foo"
    u.password = "foo"

    assert !u.save
  end
  
end