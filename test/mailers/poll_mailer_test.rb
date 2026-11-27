# frozen_string_literal: true

require "test_helper"

class PollMailerTest < ActionMailer::TestCase
  test "created sends the organizer both links" do
    poll = polls(:one)

    mail = PollMailer.with(poll: poll).created

    assert_equal ["alice@example.com"], mail.to
    assert_equal "Your poll \"Team offsite planning\" is ready", mail.subject
    assert_includes mail.text_part.body.to_s, "http://example.com/#{poll.to_param}"
    assert_includes mail.text_part.body.to_s, "http://example.com/#{poll.to_param}/admin/#{poll.admin_token}"
    assert_includes mail.html_part.body.to_s, "/admin/#{poll.admin_token}"
  end

  test "final_date tells a participant the chosen date" do
    poll = polls(:one)
    option = poll_options(:half_day_workshop)
    option.update!(poll: poll, start: Time.utc(2030, 6, 16))
    poll.close!(option)

    mail = PollMailer.with(poll: poll, participant: poll_participants(:alice_one)).final_date

    assert_equal ["alice@example.com"], mail.to
    assert_equal "\"Team offsite planning\": the date is set", mail.subject
    assert_includes mail.text_part.body.to_s, "Sunday, June 16, 2030"
    assert_includes mail.text_part.body.to_s, "http://example.com/#{poll.to_param}/event.ics"
  end

  test "final_date shows a timed option in the poll's time zone" do
    poll = polls(:one)
    poll.update!(time_zone: "Europe/Warsaw")
    option = poll_options(:evening_meeting)
    option.update!(start: Time.utc(2030, 6, 15, 16, 0))
    poll.close!(option)

    mail = PollMailer.with(poll: poll, participant: poll_participants(:alice_one)).final_date

    assert_includes mail.text_part.body.to_s, "Saturday, June 15, 2030, 18:00–18:30 (Europe/Warsaw)"
  end
end
