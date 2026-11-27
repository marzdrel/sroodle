# The organizer's private page (/poll_…/admin/<token>).
class AdminsController < ApplicationController
  def show
    result = ShowFacade.call(params, cookies, request)

    render inertia: "Poll/Admin", props: result.props
  end

  def close
    result = CloseFacade.call(params)

    if result.success?
      redirect_to result.data.fetch(:admin_path), notice: "Poll closed. Everyone can now see the final date."
    else
      redirect_to result.data.fetch(:admin_path), alert: result.errors.values.to_sentence
    end
  end

  def reopen
    result = ReopenFacade.call(params)

    redirect_to result.data.fetch(:admin_path), notice: "Voting is open again."
  end
end
