class PollsController < ApplicationController
  def show
    result = ShowFacade.call(params, cookies)

    render inertia: "Poll/Show", props: result.props
  end

  def calendar
    poll = Poll.includes(:final_option).exid_loader(params.fetch(:id))
    raise ActiveRecord::RecordNotFound unless poll.final_option

    send_data(
      PollCalendar.new(poll, url: poll_url(poll)).to_ics,
      type: "text/calendar; charset=utf-8",
      filename: "#{poll.name.parameterize.presence || "event"}.ics"
    )
  end

  def new
    result = NewFacade.call(params, cookies)

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
