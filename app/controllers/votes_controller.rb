class VotesController < ApplicationController
  def create
    result = CreateFacade.call(params)

    if result.success?
      render(
        inertia: "Poll/Show",
        props: {
          poll: result.data[:poll],
          flash: { notice: "Vote was successfully created." },
        },
      )
    else
      render(
        inertia: "Poll/Show",
        props: {
          poll: result.data[:poll],
          errors: result.errors,
          flash: { alert: "Unable to create vote." },
        },
      )
    end
  end
end
