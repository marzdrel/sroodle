# frozen_string_literal: true

require "test_helper"

class Poll::FormTest < ActiveSupport::TestCase
  setup do
    @valid_attributes = {
      name: "John Doe",
      email: "john@example.com",
      event: "Team Meeting",
      description: "Weekly team meeting to discuss project progress",
      creator_id: users(:alice).id
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

  test "is invalid without an email" do
    form = Poll::Form.new(@valid_attributes.merge(email: ""))
    assert_not form.valid?
    assert_includes form.errors[:email], "can't be blank"
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

  test "is invalid without a description" do
    form = Poll::Form.new(@valid_attributes.merge(description: ""))
    assert_not form.valid?
    assert_includes form.errors[:description], "can't be blank"
  end

  test "is invalid with a too short description" do
    form = Poll::Form.new(@valid_attributes.merge(description: "Too short"))
    assert_not form.valid?
    assert_includes form.errors[:description], "is too short (minimum is 10 characters)"
  end

  test "saves successfully with valid attributes" do
    form = Poll::Form.new(@valid_attributes)

    assert_difference -> { Poll.count }, 1 do
      assert form.save
    end

    assert form.poll_id.present?
    poll = Poll.find(form.poll_id)
    assert_equal @valid_attributes[:event], poll.name
    assert_equal @valid_attributes[:description], poll.description
  end

  test "creates a new user if the email doesn't exist" do
    form = Poll::Form.new(@valid_attributes.merge(email: "new_user@example.com"))

    assert_difference -> { User.count }, 1 do
      assert form.save
    end

    user = User.find_by(email: "new_user@example.com")
    assert user.present?
  end

  test "uses existing user if the email exists" do
    form = Poll::Form.new(@valid_attributes)

    assert_no_difference -> { User.count } do
      assert form.save
    end
  end
end