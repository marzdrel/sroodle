require "test_helper"

class PollsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get new_poll_path

    assert_response :success
  end
end
