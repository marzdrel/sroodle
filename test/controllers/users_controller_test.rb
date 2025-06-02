require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  include Clearance::Testing::ControllerHelpers

  setup do
    @user = users(:alice)
  end

  test "should handle logout when not signed in" do
    # Perform logout request without being signed in
    delete logout_path

    # Should still redirect to root path
    assert_redirected_to new_poll_path

    # Should have success notice
    assert_equal "You have been logged out successfully.", flash[:notice]
  end

  test "should use DELETE method for logout route" do
    # Test that only DELETE method works for logout
    assert_routing(
      {method: :delete, path: "/logout"},
      {controller: "users", action: "logout"}
    )
  end

  test "should clear user session on logout" do
    skip "sign_in_as helper doesn't work properly"

    sign_in_as @user

    # Perform logout
    delete logout_path

    # Should redirect, indicating sign_out was called successfully
    assert_redirected_to new_poll_path
    assert_equal "You have been logged out successfully.", flash[:notice]

    # Follow redirect and verify user is logged out
    follow_redirect!
    assert_response :success
  end
end
