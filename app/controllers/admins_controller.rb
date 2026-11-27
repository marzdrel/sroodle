# The organizer's private pages (/poll_…/admin/<token>).
class AdminsController < ApplicationController
  def show
    result = ShowFacade.call(params, cookies, request)

    render inertia: "Poll/Admin", props: result.props
  end

  def edit
    result = EditFacade.call(params)

    render inertia: "Poll/Edit", props: result.props
  end

  def update
    result = UpdateFacade.call(params)

    if result.success?
      redirect_to result.data.fetch(:admin_path), notice: "Poll updated."
    else
      render inertia: "Poll/Edit", props: result.props
    end
  end

  def destroy
    DestroyFacade.call(params)

    redirect_to new_poll_path, notice: "The poll was deleted."
  end

  def remove_participant
    result = RemoveParticipantFacade.call(params)

    redirect_to result.data.fetch(:admin_path), notice: "Removed #{result.data.fetch(:name)}'s answers."
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
