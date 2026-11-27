# frozen_string_literal: true

require "test_helper"

class PollCalendarTest < ActiveSupport::TestCase
  setup do
    @poll = polls(:one)
  end

  test "a timed option becomes an event with UTC start and end" do
    option = poll_options(:evening_meeting)
    option.update!(start: Time.utc(2030, 6, 15, 18, 0))
    @poll.close!(option)

    ics = PollCalendar.new(@poll, url: "https://sroodle.test/poll_1").to_ics

    assert ics.start_with?("BEGIN:VCALENDAR\r\n")
    assert_includes ics, "DTSTART:20300615T180000Z\r\n"
    assert_includes ics, "DTEND:20300615T183000Z\r\n"
    assert_includes ics, "SUMMARY:Team offsite planning\r\n"
    assert_includes ics, "URL:https://sroodle.test/poll_1\r\n"
    assert ics.end_with?("END:VCALENDAR\r\n")
  end

  test "an all-day option becomes a date-only event" do
    option = poll_options(:half_day_workshop)
    option.update!(poll: @poll, start: Time.utc(2030, 6, 16))
    @poll.close!(option)

    ics = PollCalendar.new(@poll, url: "https://sroodle.test/poll_1").to_ics

    assert_includes ics, "DTSTART;VALUE=DATE:20300616\r\n"
    assert_includes ics, "DTEND;VALUE=DATE:20300617\r\n"
  end

  test "escapes text and folds long lines" do
    @poll.update!(description: "Bring snacks, drinks; and games\n" + ("x" * 100))
    @poll.close!(poll_options(:morning_meeting))

    ics = PollCalendar.new(@poll, url: "https://sroodle.test/poll_1").to_ics

    assert_includes ics, 'DESCRIPTION:Bring snacks\, drinks\; and games\n'
    assert(ics.split("\r\n").all? { it.bytesize <= 75 })
  end
end
