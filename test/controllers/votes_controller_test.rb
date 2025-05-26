require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = polls(:one)
    @poll_option = poll_options(:morning_meeting)
  end

  # test "should create vote" do
  #   assert_difference("Poll::Vote.count") do
  #     post poll_votes_path(@poll), params: {poll_option_id: @poll_option.id}
  #   end
  #
  #   assert_response :success
  # end

  test "should handle vote creation failure" do
    assert_no_difference("Poll::Vote.count") do
      post poll_votes_path(@poll), params: {}
    end

    assert_response :bad_request
  end
end
