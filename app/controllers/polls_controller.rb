class PollsController < ApplicationController
  def index
    result = IndexFacade.call(params)

    render(
      inertia: "Poll/Index",
      props: result.data.merge(new_poll_path: new_poll_path)
    )
  end

  def show
    result = ShowFacade.call(params)

    render(
      inertia: "Poll/Show",
      props: result.data.merge(new_poll_path: new_poll_path)
    )
  end

  def new
    result = NewFacade.call(params)

    render(
      inertia: "Poll/New",
      props: {
        poll: result.data,
        new_poll_path: new_poll_path
      }
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
          new_poll_path: new_poll_path
        }
      )
    end
  end
end
