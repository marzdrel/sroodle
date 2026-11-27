require "test_helper"

class PollsControllerTest < ActionDispatch::IntegrationTest
  test "shows the new poll form" do
    get new_poll_path

    assert_response :success
    assert_equal "Poll/New", inertia_component
  end

  test "creating a poll redirects the organizer to the admin page" do
    assert_difference -> { Poll.count }, 1 do
      post polls_path, params: {
        poll: {
          name: "Carol",
          email: "",
          event: "Board game night",
          description: "",
          end_voting_at: 1.week.from_now.to_date.iso8601,
          dates: [2.weeks.from_now.to_date.iso8601, 3.weeks.from_now.to_date.iso8601]
        }
      }
    end

    poll = Poll.order(:id).last
    assert_redirected_to poll_admin_path(poll, token: poll.admin_token)
    assert_equal "Carol", poll.organizer_name
  end

  test "invalid input re-renders the form" do
    assert_no_difference -> { Poll.count } do
      post polls_path, params: {poll: {name: "", event: ""}}
    end

    assert_response :success
    assert_equal "Poll/New", inertia_component
  end
end
