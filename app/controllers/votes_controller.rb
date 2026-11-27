class VotesController < ApplicationController
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
end
