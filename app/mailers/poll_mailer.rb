# frozen_string_literal: true

class PollMailer < ApplicationMailer
  # Sent to the organizer right after creating a poll, so the private admin
  # link isn't lost.
  def created
    @poll = params.fetch(:poll)
    @public_url = poll_url(@poll)
    @admin_url = poll_admin_url(@poll, token: @poll.admin_token)

    mail to: @poll.organizer_email, subject: "Your poll \"#{@poll.name}\" is ready"
  end

  # Sent to each participant who left an email address when the organizer
  # picks the final date.
  def final_date
    @poll = params.fetch(:poll)
    @participant = params.fetch(:participant)
    @option = @poll.final_option
    @poll_url = poll_url(@poll)
    @calendar_url = poll_calendar_url(@poll)

    mail to: @participant.email, subject: "\"#{@poll.name}\": the date is set"
  end

  private

  helper_method def option_label(option)
    if option.duration_minutes >= Poll::OptionsInput::ALL_DAY
      option.start.utc.strftime("%A, %B %-d, %Y")
    else
      local = option.start.in_time_zone(@poll.zone)
      ending = local + option.duration_minutes.minutes

      "#{local.strftime("%A, %B %-d, %Y, %H:%M")}–#{ending.strftime("%H:%M")} (#{@poll.time_zone})"
    end
  end
end
