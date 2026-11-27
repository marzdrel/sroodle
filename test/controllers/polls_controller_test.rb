require "test_helper"

class PollsControllerTest < ActionDispatch::IntegrationTest
  test "shows the new poll form" do
    get new_poll_path

    assert_response :success
    assert_equal "Poll/New", inertia_component
    assert_equal [], inertia_props["my_polls"]
  end

  test "there is no public list of polls" do
    get "/polls"

    assert_response :not_found
  end

  test "the home page lists the polls this browser created" do
    post polls_path, params: {
      poll: {
        name: "Carol",
        event: "Board game night",
        end_voting_at: 1.week.from_now.to_date.iso8601,
        options: [
          {date: 2.weeks.from_now.to_date.iso8601, time: "", duration_minutes: 1440},
          {date: 3.weeks.from_now.to_date.iso8601, time: "", duration_minutes: 1440}
        ]
      }
    }

    get new_poll_path

    assert_equal ["Board game night"], inertia_props["my_polls"].map { it["name"] }
    assert_no_match(/@example\.com/, response.body)
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
          options: [
            {date: 2.weeks.from_now.to_date.iso8601, time: "", duration_minutes: 1440},
            {date: 3.weeks.from_now.to_date.iso8601, time: "18:00", duration_minutes: 90}
          ]
        }
      }
    end

    poll = Poll.order(:id).last
    assert_redirected_to poll_admin_path(poll, token: poll.admin_token)
    assert_equal "Carol", poll.organizer_name

    follow_redirect!
    assert_equal "Poll/Admin", inertia_component
    assert_equal "Poll created. Save the admin link below.", inertia_props.dig("flash", "notice")
    assert_equal "http://www.example.com/#{poll.to_param}", inertia_props.dig("links", "public")

    get poll_path(poll)
    assert_equal poll_admin_path(poll, token: poll.admin_token), inertia_props["admin_path"]
  end

  test "invalid input re-renders the form" do
    assert_no_difference -> { Poll.count } do
      post polls_path, params: {poll: {name: "", event: ""}}
    end

    assert_response :success
    assert_equal "Poll/New", inertia_component
  end

  test "the poll page shows the real answers" do
    poll = polls(:one)

    get poll_path(poll)

    assert_response :success
    assert_equal "Poll/Show", inertia_component
    assert_equal %w[Alice Bob], inertia_props["participants"].map { it["name"] }
    assert_equal 3, inertia_props["options"].size
    assert_not_includes response.body, "alice@example.com"
  end

  test "the poll page shows the final date once picked" do
    poll = polls(:one)
    option = poll_options(:evening_meeting)
    poll.close!(option)

    get poll_path(poll)

    assert_equal option.to_param, inertia_props["final_option_id"]
    assert_equal poll_calendar_path(poll), inertia_props["calendar_path"]
    assert_not inertia_props["voting_open"]
  end

  test "the calendar file is only available once a date is picked" do
    poll = polls(:one)

    get poll_calendar_path(poll)
    assert_response :not_found

    poll.close!(poll_options(:evening_meeting))
    get poll_calendar_path(poll)

    assert_response :success
    assert_equal "text/calendar", response.media_type
    assert_includes response.body, "SUMMARY:Team offsite planning"
  end

  test "creating a poll emails the links when an email is given" do
    assert_enqueued_emails 1 do
      post polls_path, params: {poll: poll_params.merge(email: "carol@example.com")}
    end
  end

  test "creating a poll without an email sends nothing" do
    assert_no_enqueued_emails do
      post polls_path, params: {poll: poll_params.merge(email: "")}
    end
  end

  private

  def poll_params
    {
      name: "Carol",
      event: "Board game night",
      end_voting_at: 1.week.from_now.to_date.iso8601,
      options: [
        {date: 2.weeks.from_now.to_date.iso8601, time: "", duration_minutes: 1440},
        {date: 3.weeks.from_now.to_date.iso8601, time: "", duration_minutes: 1440}
      ]
    }
  end
end
