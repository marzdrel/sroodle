require "test_helper"

class Poll::VoteTest < ActiveSupport::TestCase
  set_fixture_class poll_votes: Poll::Vote

  test "fixtures are valid" do
    assert poll_votes(:alice_morning_yes).valid?, "poll_votes(:alice_morning_yes) should be valid"
    assert poll_votes(:alice_afternoon_maybe).valid?, "poll_votes(:alice_afternoon_maybe) should be valid"
    assert poll_votes(:alice_evening_no).valid?, "poll_votes(:alice_evening_no) should be valid"
    assert poll_votes(:bob_morning_maybe).valid?, "poll_votes(:bob_morning_maybe) should be valid"
    assert poll_votes(:bob_afternoon_yes).valid?, "poll_votes(:bob_afternoon_yes) should be valid"
    assert poll_votes(:bob_standup_yes).valid?, "poll_votes(:bob_standup_yes) should be valid"
    assert poll_votes(:alice_workshop_no).valid?, "poll_votes(:alice_workshop_no) should be valid"
  end

  test "belongs to poll" do
    assert_must belong_to(:poll), Poll::Vote.new
  end

  test "belongs to option" do
    assert_must belong_to(:option), Poll::Vote.new
  end

  test "belongs to participant" do
    assert_must belong_to(:participant), Poll::Vote.new
  end

  test "poll association works" do
    vote = poll_votes(:alice_morning_yes)
    assert_equal polls(:one), vote.poll
  end

  test "option association works" do
    vote = poll_votes(:alice_morning_yes)
    assert_equal poll_options(:morning_meeting), vote.option
  end

  test "rejects unknown responses" do
    vote = poll_votes(:alice_morning_yes)
    vote.response = "perhaps"

    assert_not vote.valid?
  end

  test "participant association works" do
    vote = poll_votes(:alice_morning_yes)
    assert_equal poll_participants(:alice_one), vote.participant
  end

  test "has valid response values from fixtures" do
    assert_equal "yes", poll_votes(:alice_morning_yes).response
    assert_equal "maybe", poll_votes(:alice_afternoon_maybe).response
    assert_equal "no", poll_votes(:alice_evening_no).response
    assert_equal "maybe", poll_votes(:bob_morning_maybe).response
    assert_equal "yes", poll_votes(:bob_afternoon_yes).response
    assert_equal "yes", poll_votes(:bob_standup_yes).response
    assert_equal "no", poll_votes(:alice_workshop_no).response
  end

  test "different participants can vote on same option" do
    alice_vote = poll_votes(:alice_morning_yes)
    bob_vote = poll_votes(:bob_morning_maybe)

    assert_equal alice_vote.option, bob_vote.option
    assert_not_equal alice_vote.participant, bob_vote.participant
    assert alice_vote.valid?
    assert bob_vote.valid?
  end

  test "same participant can vote on different options in same poll" do
    alice_morning = poll_votes(:alice_morning_yes)
    alice_afternoon = poll_votes(:alice_afternoon_maybe)

    assert_equal alice_morning.poll, alice_afternoon.poll
    assert_equal alice_morning.participant, alice_afternoon.participant
    assert_not_equal alice_morning.option, alice_afternoon.option
    assert alice_morning.valid?
    assert alice_afternoon.valid?
  end
end
