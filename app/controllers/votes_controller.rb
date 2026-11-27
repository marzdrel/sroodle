class VotesController < ApplicationController
  before_action :require_open_voting

  def new
    result = NewFacade.call(params, cookies)

    if result.success?
      render inertia: "Vote/New", props: result.props
    else
      redirect_to edit_poll_vote_path(params.fetch(:id))
    end
  end

  def create
    result = SaveFacade.call(params, cookies, mode: :create)

    if result.success?
      redirect_to edit_poll_vote_path(params.fetch(:id)), notice: "Thanks! Your answers are saved."
    else
      render inertia: "Vote/New", props: result.props
    end
  end

  def edit
    result = EditFacade.call(params, cookies)

    if result.success?
      render inertia: "Vote/Edit", props: result.props
    else
      redirect_to new_poll_vote_path(params.fetch(:id))
    end
  end

  def update
    result = SaveFacade.call(params, cookies, mode: :update)

    if result.success?
      redirect_to edit_poll_vote_path(params.fetch(:id)), notice: "Your answers are updated."
    elsif result.data[:participant_missing]
      redirect_to new_poll_vote_path(params.fetch(:id))
    else
      render inertia: "Vote/Edit", props: result.props
    end
  end

  private

  def require_open_voting
    poll = Poll.exid_loader(params.fetch(:id))
    return if poll.voting_open?

    redirect_to poll_path(poll), alert: "Voting on this poll has closed."
  end
end
