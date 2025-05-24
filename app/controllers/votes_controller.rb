class VotesController < ApplicationController
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
        inertia: "Poll/Show",
        props: {
          poll: result.data[:poll],
          flash: {notice: "Vote was successfully created."}
        }
      )
    else
      render(
        inertia: "Poll/Show",
        props: {
          poll: result.data[:poll],
          errors: result.errors,
          flash: {alert: "Unable to create vote."}
        }
      )
    end
  end
end
