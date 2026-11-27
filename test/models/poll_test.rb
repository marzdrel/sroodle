require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert polls(:one).valid?, "polls(:one) should be valid"
    assert polls(:two).valid?, "polls(:two) should be valid"
  end

  test "associations" do
    assert_must have_many(:options).dependent(:destroy), Poll.new
    assert_must have_many(:participants).dependent(:destroy), Poll.new
    assert_must have_many(:votes).dependent(:delete_all), Poll.new
  end

  test "requires a name" do
    assert_must validate_presence_of(:name), Poll.new

    assert_must(
      validate_length_of(:name).is_at_least(5).is_at_most(100),
      Poll.new
    )
  end

  test "requires an organizer name" do
    assert_must validate_presence_of(:organizer_name), Poll.new

    assert_must(
      validate_length_of(:organizer_name).is_at_least(2).is_at_most(50),
      Poll.new
    )
  end

  test "organizer email is optional but must be valid" do
    poll = polls(:two)
    assert_nil poll.organizer_email
    assert poll.valid?

    poll.organizer_email = "not-an-email"
    assert_not poll.valid?
  end

  test "has exid functionality" do
    poll = polls(:one)

    assert_not_nil poll.eid
    assert_equal poll.exid_value, poll.to_param
  end

  test "generates an eid and an admin token on create" do
    poll = Poll.create!(
      name: "Board game night",
      organizer_name: "Carol",
      end_voting_at: 1.week.from_now
    )

    assert_match(/\A[0-9a-f-]{36}\z/, poll.eid)
    assert_equal 24, poll.admin_token.length
  end

  test "admin_token? compares safely" do
    poll = polls(:one)

    assert poll.admin_token?(poll.admin_token)
    assert_not poll.admin_token?("wrong")
    assert_not poll.admin_token?(nil)
    assert_not poll.admin_token?("")
  end

  test "destroying a poll removes its participants and votes" do
    poll = polls(:one)

    assert_difference -> { Poll::Participant.count }, -2 do
      assert_difference -> { Poll::Vote.count }, -5 do
        poll.destroy!
      end
    end
  end
end
