# The organizer's private page (/poll_…/admin/<token>).
class AdminsController < ApplicationController
  def show
    result = ShowFacade.call(params, cookies, request)

    render inertia: "Poll/Admin", props: result.props
  end
end
