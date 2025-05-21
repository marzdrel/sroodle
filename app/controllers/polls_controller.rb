class PollsController < ApplicationController
  def index
    result = IndexFacade.call(params)

    render(
      inertia: "Poll/Index",
      props: result.data,
    )
  end

  def show
    render plain: "Not implemented"
  end

  def new
    result = NewFacade.call(params)

    render(
      inertia: "Poll/New",
      props: {
        poll: result.data,
      },
    )
  end

  def create
    result = CreateFacade.call(params)

    if result.success?
      redirect_to polls_path, notice: "Poll was successfully created."
    else
      render(
        inertia: "Poll/New",
        props: {
          poll: result.data,
          errors: result.errors,
        },
      )
    end
  end
end
