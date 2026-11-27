# frozen_string_literal: true

require "test_helper"

class Poll::OptionsInputTest < ActiveSupport::TestCase
  setup do
    @zone = ActiveSupport::TimeZone["America/New_York"]
  end

  test "an all-day option starts at midnight UTC" do
    input = Poll::OptionsInput.new([{date: "2030-01-15", time: ""}], zone: @zone)

    assert input.valid?
    entry = input.entries.sole
    assert_equal Time.utc(2030, 1, 15), entry.start
    assert_equal 1440, entry.duration_minutes
    assert entry.all_day?
  end

  test "a timed option is read in the given time zone" do
    input = Poll::OptionsInput.new([{date: "2030-01-15", time: "18:00", duration_minutes: "120"}], zone: @zone)

    assert input.valid?
    assert_equal Time.utc(2030, 1, 15, 23, 0), input.entries.sole.start
    assert_equal 120, input.entries.sole.duration_minutes
  end

  test "drops duplicates and sorts by start" do
    input = Poll::OptionsInput.new(
      [
        {date: "2030-01-16", time: ""},
        {date: "2030-01-15", time: "10:00", duration_minutes: 60},
        {date: "2030-01-15", time: "10:00", duration_minutes: 60}
      ],
      zone: @zone
    )

    assert_equal 2, input.entries.size
    assert_equal Date.new(2030, 1, 15), input.entries.first.start.to_date
  end

  test "rejects bad times and durations" do
    bad_time = Poll::OptionsInput.new([{date: "2030-01-15", time: "25:00", duration_minutes: 60}], zone: @zone)
    bad_duration = Poll::OptionsInput.new([{date: "2030-01-15", time: "10:00", duration_minutes: 7}], zone: @zone)

    assert_not bad_time.valid?
    assert_equal ["contains an invalid time"], bad_time.errors
    assert_not bad_duration.valid?
    assert_equal ["contains an invalid duration"], bad_duration.errors
  end

  test "handles a missing or non-array value" do
    assert Poll::OptionsInput.new(nil, zone: @zone).entries.empty?
  end
end
