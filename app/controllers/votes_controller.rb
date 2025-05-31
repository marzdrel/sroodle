class VotesController < ApplicationController
  def index
    redirect_to new_poll_vote_path(params.fetch(:poll_id))
  end

  def new
    result = NewFacade.call(params, current_user)

    sign_in(User.first) unless current_user

    # If the the current user already voted on this poll, redirect to edit
    # instead.

    if result.success?
      render(
        inertia: "Vote/New",
        props: result.props
      )
    else
      redirect_to edit_poll_vote_path
    end
  end

  def edit
    result = EditFacade.call(params, current_user)

    render(
      inertia: "Vote/Edit",
      props: result.props.merge(flash: flash.to_hash)
    )
  end

  def create
    result = CreateFacade.call(params, current_user)

    if result.success?
      redirect_to(
        edit_poll_vote_path(params.fetch(:poll_id)),
        notice: "Vote was successfully created."
      )
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
    result = UpdateFacade.call(params, current_user)

    if result.success?
      redirect_to(
        edit_poll_vote_path,
        notice: "Vote was successfully updated."
      )
    else
      render(
        inertia: "Vote/Edit",
        props: result.props.merge(
          votes: result.data[:vote],
          flash: {alert: "Unable to update vote."}
        )
      )
    end
  end
end
