# frozen_string_literal: true

require "test_helper"

class Poll::FormTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      name: "John Doe",
      email: "john@example.com",
      event: "Team Meeting",
      description: "Weekly team meeting to discuss project progress",
      end_voting_at: 1.month.from_now.to_date.iso8601,
      dates: ["2023-10-01", "2023-10-02"]
    }
  end

  test "is valid with valid attributes" do
    form = Poll::Form.new(@valid_attributes)
    assert form.valid?
  end

  test "is invalid without a name" do
    form = Poll::Form.new(@valid_attributes.merge(name: ""))
    assert_not form.valid?
    assert_includes form.errors[:name], "can't be blank"
  end

  test "is invalid with a too short name" do
    form = Poll::Form.new(@valid_attributes.merge(name: "A"))
    assert_not form.valid?
    assert_includes form.errors[:name], "is too short (minimum is 2 characters)"
  end

  test "is valid without an email" do
    form = Poll::Form.new(@valid_attributes.merge(email: ""))
    assert form.valid?
  end

  test "is invalid with an invalid email format" do
    form = Poll::Form.new(@valid_attributes.merge(email: "invalid-email"))
    assert_not form.valid?
    assert_includes form.errors[:email], "is invalid"
  end

  test "is invalid without an event name" do
    form = Poll::Form.new(@valid_attributes.merge(event: ""))
    assert_not form.valid?
    assert_includes form.errors[:event], "can't be blank"
  end

  test "is invalid with a too short event name" do
    form = Poll::Form.new(@valid_attributes.merge(event: "Meet"))
    assert_not form.valid?
    assert_includes form.errors[:event], "is too short (minimum is 5 characters)"
  end

  test "is valid without a description" do
    form = Poll::Form.new(@valid_attributes.merge(description: ""))

    assert form.valid?
    assert_equal form.errors[:description], []
  end

  test "is invalid without an end_voting_at" do
    form = Poll::Form.new(@valid_attributes.merge(end_voting_at: nil))
    assert_not form.valid?
    assert_includes form.errors[:end_voting_at], "can't be blank"
  end

  test "ends voting at the end of the chosen day in UTC by default" do
    day = 1.month.from_now.to_date
    form = Poll::Form.new(@valid_attributes.merge(end_voting_at: day.iso8601))

    assert form.save
    assert_equal Time.utc(day.year, day.month, day.day, 23, 59, 59), form.poll.end_voting_at.change(usec: 0)
    assert_equal "UTC", form.poll.time_zone
  end

  test "ends voting at the end of the chosen day in the organizer's time zone" do
    day = 1.month.from_now.to_date
    form = Poll::Form.new(
      @valid_attributes.merge(end_voting_at: day.iso8601, time_zone: "Europe/Warsaw")
    )

    assert form.save
    poll = form.poll

    assert_equal "Europe/Warsaw", poll.time_zone
    local = poll.end_voting_at.in_time_zone("Europe/Warsaw")
    assert_equal [day, 23, 59], [local.to_date, local.hour, local.min]
  end

  test "falls back to UTC for an unknown time zone" do
    form = Poll::Form.new(@valid_attributes.merge(time_zone: "Mars/Olympus"))

    assert form.save
    assert_equal "UTC", form.poll.time_zone
  end

  test "is invalid with a deadline in the past" do
    form = Poll::Form.new(@valid_attributes.merge(end_voting_at: 2.days.ago.to_date.iso8601))

    assert_not form.valid?
    assert_includes form.errors[:end_voting_at], "must be today or later"
  end

  test "is invalid with a deadline that is not a date" do
    form = Poll::Form.new(@valid_attributes.merge(end_voting_at: "someday"))

    assert_not form.valid?
    assert_includes form.errors[:end_voting_at], "is not a valid date"
  end

  test "saves successfully with valid attributes" do
    form = Poll::Form.new(@valid_attributes)

    assert_difference -> { Poll.count }, 1 do
      assert form.save
    end

    poll = Poll.last

    assert_equal @valid_attributes[:event], poll.name
    assert_equal @valid_attributes[:description], poll.description
  end

  test "stores the organizer on the poll" do
    form = Poll::Form.new(@valid_attributes)

    assert form.save
    assert_equal "John Doe", form.poll.organizer_name
    assert_equal "john@example.com", form.poll.organizer_email
    assert form.poll.admin_token.present?
  end

  test "stores a blank email as nil" do
    form = Poll::Form.new(@valid_attributes.merge(email: ""))

    assert form.save
    assert_nil form.poll.organizer_email
  end

  test "creates one all-day option per unique date, sorted" do
    form = Poll::Form.new(
      @valid_attributes.merge(dates: ["2023-10-03", "2023-10-01", "2023-10-03"])
    )

    assert form.save
    assert_equal(
      [Date.new(2023, 10, 1), Date.new(2023, 10, 3)],
      form.poll.options.map { it.start.to_date }
    )
    assert(form.poll.options.all? { it.duration_minutes == 1440 })
  end

  test "is invalid when a date can't be parsed" do
    form = Poll::Form.new(@valid_attributes.merge(dates: ["2023-10-01", "nope"]))

    assert_not form.valid?
    assert_includes form.errors[:dates], "contains invalid date format"
  end
end
