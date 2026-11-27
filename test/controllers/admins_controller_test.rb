require "test_helper"

class AdminsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = polls(:one)
  end

  test "the admin link shows the organizer page" do
    get poll_admin_path(@poll, token: @poll.admin_token)

    assert_response :success
    assert_equal "Poll/Admin", inertia_component
    assert_equal "http://www.example.com/#{@poll.to_param}", inertia_props.dig("links", "public")
    assert_equal 2, inertia_props["participants_count"]
  end

  test "a wrong admin token is not found" do
    get poll_admin_path(@poll, token: polls(:two).admin_token)

    assert_response :not_found
  end

  test "the organizer can pick the final date" do
    option = poll_options(:afternoon_meeting)

    post close_poll_admin_path(@poll, token: @poll.admin_token), params: {option_id: option.to_param}

    assert_redirected_to poll_admin_path(@poll, token: @poll.admin_token)
    assert_equal option, @poll.reload.final_option
    assert @poll.closed?

    follow_redirect!
    assert inertia_props["closed"]
    assert_equal option.to_param, inertia_props["final_option_id"]
  end

  test "picking a date of another poll is rejected" do
    post close_poll_admin_path(@poll, token: @poll.admin_token),
      params: {option_id: poll_options(:quick_standup).to_param}

    assert_redirected_to poll_admin_path(@poll, token: @poll.admin_token)
    assert_not @poll.reload.closed?
    assert_equal "Pick one of the poll's dates.", flash[:alert]
  end

  test "closing needs the admin token" do
    post close_poll_admin_path(@poll, token: "wrong"),
      params: {option_id: poll_options(:afternoon_meeting).to_param}

    assert_response :not_found
    assert_not @poll.reload.closed?
  end

  test "the organizer can reopen voting" do
    @poll.close!(poll_options(:morning_meeting))

    post reopen_poll_admin_path(@poll, token: @poll.admin_token)

    assert_redirected_to poll_admin_path(@poll, token: @poll.admin_token)
    assert_not @poll.reload.closed?
  end

  test "the admin page lists options with counts and the best ones" do
    get poll_admin_path(@poll, token: @poll.admin_token)

    options = inertia_props["options"]
    assert_equal 3, options.size
    assert_equal({"yes" => 1, "maybe" => 1, "no" => 0}, options.first["counts"])
    assert_equal 2, inertia_props["best_option_ids"].size
  end

  test "the edit page shows the current values" do
    get edit_poll_admin_path(@poll, token: @poll.admin_token)

    assert_response :success
    assert_equal "Poll/Edit", inertia_component
    assert_equal "Team offsite planning", inertia_props.dig("values", "event")
    assert_equal 3, inertia_props.dig("values", "options").size
    assert_equal "09:00", inertia_props.dig("values", "options", 0, "time")
  end

  test "the organizer can update the poll" do
    get edit_poll_admin_path(@poll, token: @poll.admin_token)
    values = inertia_props["values"]

    patch update_poll_admin_path(@poll, token: @poll.admin_token),
      params: {poll: values.merge("event" => "Offsite, take two")}

    assert_redirected_to poll_admin_path(@poll, token: @poll.admin_token)
    assert_equal "Offsite, take two", @poll.reload.name
  end

  test "invalid edits re-render the form with errors" do
    patch update_poll_admin_path(@poll, token: @poll.admin_token),
      params: {poll: {event: "", end_voting_at: 1.week.from_now.to_date.iso8601, options: []}}

    assert_response :success
    assert_equal "Poll/Edit", inertia_component
    assert inertia_props.dig("errors", "event").present?
    assert inertia_props.dig("errors", "options").present?
    assert_equal "Team offsite planning", @poll.reload.name
  end

  test "the organizer can delete the poll" do
    assert_difference -> { Poll.count }, -1 do
      delete destroy_poll_admin_path(@poll, token: @poll.admin_token)
    end

    assert_redirected_to new_poll_path
  end

  test "the organizer can remove a participant" do
    bob = poll_participants(:bob_one)

    assert_difference -> { @poll.participants.count }, -1 do
      delete remove_participant_poll_admin_path(@poll, token: @poll.admin_token, participant_id: bob.to_param)
    end

    assert_redirected_to poll_admin_path(@poll, token: @poll.admin_token)
    assert_equal "Removed Bob's answers.", flash[:notice]
  end

  test "removing a participant of another poll is not found" do
    assert_no_difference -> { Poll::Participant.count } do
      delete remove_participant_poll_admin_path(
        @poll, token: @poll.admin_token, participant_id: poll_participants(:bob_two).to_param
      )
    end

    assert_response :not_found
  end

  test "editing and deleting need the admin token" do
    get edit_poll_admin_path(@poll, token: "wrong")
    assert_response :not_found

    patch update_poll_admin_path(@poll, token: "wrong"), params: {poll: {event: "Hacked poll"}}
    assert_response :not_found

    assert_no_difference -> { Poll.count } do
      delete destroy_poll_admin_path(@poll, token: "wrong")
    end
    assert_response :not_found
  end

  test "the admin page lists participants with their emails" do
    get poll_admin_path(@poll, token: @poll.admin_token)

    assert_equal ["Alice", "Bob"], inertia_props["participants"].map { it["name"] }
    assert_equal "alice@example.com", inertia_props.dig("participants", 0, "email")
  end
end
