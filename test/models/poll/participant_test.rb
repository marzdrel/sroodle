# frozen_string_literal: true

require "test_helper"

class Poll::ParticipantTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert poll_participants(:alice_one).valid?
    assert poll_participants(:bob_one).valid?
  end

  test "associations" do
    assert_must belong_to(:poll), Poll::Participant.new
    assert_must have_many(:votes).dependent(:delete_all), Poll::Participant.new
  end

  test "requires a name between 2 and 50 characters" do
    assert_must validate_presence_of(:name), Poll::Participant.new

    assert_must(
      validate_length_of(:name).is_at_least(2).is_at_most(50),
      Poll::Participant.new
    )
  end

  test "email is optional but must be valid" do
    participant = poll_participants(:bob_one)
    assert participant.valid?

    participant.email = "nope"
    assert_not participant.valid?
  end

  test "generates a token and an eid" do
    participant = polls(:one).participants.create!(name: "Carol")

    assert_equal 24, participant.token.length
    assert participant.eid.present?
    assert participant.to_param.start_with?("part_")
  end
end
