class PollsController < ApplicationController
  def new
    render(
      inertia: "Poll/New",
      props: {
        poll: {
          name: params[:name] || "My Event",
          email: params[:email] || "me@example.com",
          event: params[:event] || "My Event",
          description: params[:description] || "My Event Description",
        }
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
          errors: result.errors
        }
      )
    end
  end
end
