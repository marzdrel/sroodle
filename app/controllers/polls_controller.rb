class PollsController < ApplicationController
  def index
    result = IndexFacade.call(params)

    render inertia: "Poll/Index", props: result.props
  end

  def show
    result = ShowFacade.call(params, cookies)

    render inertia: "Poll/Show", props: result.props
  end

  def new
    result = NewFacade.call(params)

    render inertia: "Poll/New", props: result.props
  end

  def create
    result = CreateFacade.call(params, cookies)

    if result.success?
      redirect_to result.data.fetch(:admin_path), notice: "Poll created. Save the admin link below."
    else
      render inertia: "Poll/New", props: result.props
    end
  end
end
