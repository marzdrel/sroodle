# frozen_string_literal: true

require "test_helper"

class Poll::Vote::FormTest < ActiveSupport::TestCase
  setup do
    @poll = polls(:one)
    @responses = @poll.options.to_h { [it.to_param, "yes"] }
  end

  test "creates a participant with their votes" do
    form = Poll::Vote::Form.new(
      {name: "Carol", email: "", responses: @responses},
      poll: @poll
    )

    assert_difference -> { @poll.participants.count }, 1 do
      assert_difference -> { Poll::Vote.count }, 3 do
        assert form.save
      end
    end

    assert_equal "Carol", form.participant.name
    assert_nil form.participant.email
    assert_equal %w[yes yes yes], form.participant.votes.pluck(:response)
  end

  test "replaces the answers of an existing participant" do
    alice = poll_participants(:alice_one)
    responses = @poll.options.to_h { [it.to_param, "no"] }

    form = Poll::Vote::Form.new(
      {name: "Alice B.", responses: responses},
      poll: @poll,
      participant: alice
    )

    assert_no_difference -> { Poll::Participant.count } do
      assert_no_difference -> { Poll::Vote.count } do
        assert form.save
      end
    end

    assert_equal "Alice B.", alice.reload.name
    assert_equal %w[no no no], alice.votes.pluck(:response)
  end

  test "requires an answer for every option" do
    form = Poll::Vote::Form.new(
      {name: "Carol", responses: @responses.first(1).to_h},
      poll: @poll
    )

    assert_not form.save
    assert_includes form.errors[:responses], "must include a response for all proposed dates"
  end

  test "rejects unknown answers" do
    form = Poll::Vote::Form.new(
      {name: "Carol", responses: @responses.transform_values { "perhaps" }},
      poll: @poll
    )

    assert_not form.save
    assert_includes form.errors[:responses], "must be 'yes', 'maybe', or 'no'"
  end

  test "ignores answers for options of another poll" do
    other_option = poll_options(:quick_standup)

    form = Poll::Vote::Form.new(
      {name: "Carol", responses: @responses.merge(other_option.to_param => "yes")},
      poll: @poll
    )

    assert form.save
    assert_not_includes form.participant.votes.map(&:option), other_option
  end

  test "keeps previous answers when the new ones are invalid" do
    alice = poll_participants(:alice_one)

    form = Poll::Vote::Form.new(
      {name: "", responses: @responses},
      poll: @poll,
      participant: alice
    )

    assert_not form.save
    assert_equal 3, alice.votes.count
  end
end
