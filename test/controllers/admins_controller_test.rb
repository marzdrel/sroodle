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
end
