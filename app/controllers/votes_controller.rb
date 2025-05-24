class VotesController < ApplicationController
  def index
    redirect_to new_poll_vote_path(params.fetch(:poll_id))
  end

  def new
    result = NewFacade.call(params)

    render(
      inertia: "Vote/New",
      props: {
        poll: result.data
      }
    )
  end

  def create
    result = CreateFacade.call(params)

    if result.success?
      render(
        inertia: "Vote/New",
        props: {
          poll: result.data[:poll],
          flash: {notice: "Vote was successfully created."}
        }
      )
    else
      render(
        inertia: "Vote/New",
        props: {
          poll: result.data[:poll],
          errors: result.errors,
          flash: {alert: "Unable to create vote."}
        }
      )
    end
  end
end
