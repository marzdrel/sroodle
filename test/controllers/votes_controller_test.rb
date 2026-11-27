require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @poll = polls(:one)
  end

  test "a new visitor gets the vote form" do
    get new_poll_vote_path(@poll)

    assert_response :success
    assert_equal "Vote/New", inertia_component
    assert_equal poll_votes_path(@poll), inertia_props["submit_path"]
  end

  test "voting creates a participant and remembers them" do
    assert_difference -> { @poll.participants.count }, 1 do
      post poll_votes_path(@poll), params: vote_params("Carol", "yes")
    end

    assert_redirected_to edit_poll_vote_path(@poll)

    get new_poll_vote_path(@poll)
    assert_redirected_to edit_poll_vote_path(@poll)

    get edit_poll_vote_path(@poll)
    assert_response :success
    assert_equal "Carol", inertia_props.dig("vote", "name")
  end

  test "two people in different browsers keep separate answers" do
    carol = open_session
    dave = open_session

    carol.post poll_votes_path(@poll), params: vote_params("Carol", "yes")
    dave.post poll_votes_path(@poll), params: vote_params("Dave", "no")

    carol_votes = @poll.participants.find_by!(name: "Carol").votes.pluck(:response)
    dave_votes = @poll.participants.find_by!(name: "Dave").votes.pluck(:response)

    assert_equal %w[yes yes yes], carol_votes
    assert_equal %w[no no no], dave_votes
  end

  test "editing changes only your own answers" do
    post poll_votes_path(@poll), params: vote_params("Carol", "yes")

    assert_no_difference -> { @poll.participants.count } do
      patch update_poll_votes_path(@poll), params: vote_params("Carol", "maybe")
    end

    assert_redirected_to edit_poll_vote_path(@poll)
    assert_equal %w[maybe maybe maybe], @poll.participants.find_by!(name: "Carol").votes.pluck(:response)
    assert_equal %w[yes maybe no], poll_participants(:alice_one).votes.order(:option_id).pluck(:response)
  end

  test "voting twice from the same browser doesn't duplicate the participant" do
    post poll_votes_path(@poll), params: vote_params("Carol", "yes")

    assert_no_difference -> { @poll.participants.count } do
      post poll_votes_path(@poll), params: vote_params("Carol", "no")
    end
  end

  test "edit without having voted redirects to the vote form" do
    get edit_poll_vote_path(@poll)

    assert_redirected_to new_poll_vote_path(@poll)
  end

  test "update without having voted can't touch anyone's answers" do
    assert_no_changes -> { Poll::Vote.order(:id).pluck(:response) } do
      patch update_poll_votes_path(@poll), params: vote_params("Mallory", "no")
    end

    assert_redirected_to new_poll_vote_path(@poll)
  end

  test "invalid answers re-render the form with errors" do
    assert_no_difference -> { Poll::Participant.count } do
      post poll_votes_path(@poll), params: vote_params("", "yes")
    end

    assert_response :success
    assert_equal "Vote/New", inertia_component
    assert inertia_props.dig("errors", "name").present?
  end

  test "the personal link restores the participant in a new browser" do
    alice = poll_participants(:alice_one)

    get participant_link_path(@poll, token: alice.token)
    assert_redirected_to edit_poll_vote_path(@poll)

    get edit_poll_vote_path(@poll)
    assert_equal "Alice", inertia_props.dig("vote", "name")
  end

  test "a wrong personal link is not found" do
    get participant_link_path(@poll, token: "wrong")

    assert_response :not_found
  end

  test "an unknown poll is not found" do
    get new_poll_vote_path(id: "poll_doesnotexist")

    assert_response :not_found
  end

  test "voting is blocked after the deadline" do
    @poll.update_columns(end_voting_at: 1.minute.ago)

    get new_poll_vote_path(@poll)
    assert_redirected_to poll_path(@poll)
    assert_equal "Voting on this poll has closed.", flash[:alert]

    assert_no_difference -> { Poll::Participant.count } do
      post poll_votes_path(@poll), params: vote_params("Carol", "yes")
    end
    assert_redirected_to poll_path(@poll)
  end

  test "editing is blocked after the deadline" do
    alice = poll_participants(:alice_one)
    get participant_link_path(@poll, token: alice.token)
    @poll.update_columns(end_voting_at: 1.minute.ago)

    get edit_poll_vote_path(@poll)
    assert_redirected_to poll_path(@poll)

    assert_no_changes -> { alice.votes.order(:id).pluck(:response) } do
      patch update_poll_votes_path(@poll), params: vote_params("Alice", "no")
    end
    assert_redirected_to poll_path(@poll)
  end

  test "voting is blocked once the organizer picks a date" do
    @poll.close!(poll_options(:morning_meeting))

    get new_poll_vote_path(@poll)

    assert_redirected_to poll_path(@poll)
  end

  private

  def vote_params(name, answer)
    {
      vote: {
        name: name,
        email: "",
        responses: @poll.options.to_h { [it.to_param, answer] }
      }
    }
  end
end
