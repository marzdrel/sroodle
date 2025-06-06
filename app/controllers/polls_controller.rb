class PollsController < ApplicationController
  def index
    result = IndexFacade.call(params, current_user)

    render(
      inertia: "Poll/Index",
      props: result.props
    )
  end

  def show
    result = ShowFacade.call(params, current_user)

    render(
      inertia: "Poll/Show",
      props: result.props
    )
  end

  def new
    result = NewFacade.call(params, current_user)

    render(
      inertia: "Poll/New",
      props: result.props
    )
  end

  def create
    result = CreateFacade.call(params, current_user)

    if result.success?
      redirect_to polls_path, notice: "Poll was successfully created."
    else
      render(
        inertia: "Poll/New",
        props: result.props
      )
    end
  end
end
