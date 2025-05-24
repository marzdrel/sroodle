require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert users(:alice).valid?, "users(:alice) should be valid"
    assert users(:bob).valid?, "users(:bob) should be valid"
  end

  test "includes Clearance::User functionality" do
    user = users(:alice)
    assert_respond_to user, :email
    assert_respond_to user, :encrypted_password
    assert_respond_to user, :remember_token
  end

  test "has valid email addresses in fixtures" do
    assert_equal "alice@example.com", users(:alice).email
    assert_equal "bob@example.com", users(:bob).email
  end

  test "has encrypted passwords in fixtures" do
    assert_not_nil users(:alice).encrypted_password
    assert_not_nil users(:bob).encrypted_password
  end

  test "has remember tokens in fixtures" do
    assert_not_nil users(:alice).remember_token
    assert_not_nil users(:bob).remember_token
  end
end
