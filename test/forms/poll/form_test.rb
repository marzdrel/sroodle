# frozen_string_literal: true

require "test_helper"

class Poll::FormTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      name: "John Doe",
      email: "john@example.com",
      event: "Team Meeting",
      description: "Weekly team meeting to discuss project progress",
      end_voting_at: "2023-10-15",
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

  test "converts date string to end of day for end_voting_at" do
    form = Poll::Form.new(@valid_attributes.merge(end_voting_at: "2023-10-15"))

    assert form.save

    poll = Poll.last
    expected_date = Date.parse("2023-10-15")
    assert_equal expected_date, poll.end_voting_at.to_date
    assert_equal 23, poll.end_voting_at.hour
    assert_equal 59, poll.end_voting_at.min
    assert_equal 59, poll.end_voting_at.sec
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
