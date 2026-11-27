# Personal edit links (/poll_…/p/<token>): remembers the participant in this
# browser, then opens their answers.
class ParticipantsController < ApplicationController
  def show
    poll = Poll.exid_loader(params.fetch(:id))
    participant = poll.participants.find_by!(token: params.fetch(:token))

    PollSession.new(poll, cookies).remember_participant(participant)

    redirect_to edit_poll_vote_path(poll)
  end
end
