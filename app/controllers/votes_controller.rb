class VotesController < ApplicationController
  def index
    redirect_to new_poll_vote_path(params.fetch(:poll_id))
  end

  def new
    result = NewFacade.call(params, current_user)

    render(
      inertia: "Vote/New",
      props: result.props
    )
  end

  def edit
    result = EditFacade.call(params)

    render(
      inertia: "Vote/Edit",
      props: {
        poll: result.data[:poll],
        vote: result.data[:vote],
        new_poll_path: new_poll_path
      }
    )
  end

  def create
    result = CreateFacade.call(params, current_user)

    if result.success?
      vote_id = result.data[:votes].first.to_param
      redirect_to vote_path(vote_id), notice: "Vote was successfully created."
    else
      render(
        inertia: "Vote/New",
        props: {
          poll: result.data[:poll],
          errors: result.errors,
          flash: {alert: "Unable to create vote."},
          new_poll_path: new_poll_path
        }
      )
    end
  end

  def update
    result = UpdateFacade.call(params)

    if result.success?
      render(
        inertia: "Vote/Edit",
        props: {
          poll: result.data[:poll],
          vote: result.data[:vote],
          flash: {notice: "Vote was successfully updated."},
          new_poll_path: new_poll_path
        }
      )
    else
      render(
        inertia: "Vote/Edit",
        props: {
          poll: result.data[:poll],
          vote: result.data[:vote],
          errors: result.errors,
          flash: {alert: "Unable to update vote."},
          new_poll_path: new_poll_path
        }
      )
    end
  end
end
