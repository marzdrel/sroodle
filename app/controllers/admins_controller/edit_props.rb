# frozen_string_literal: true

class AdminsController
  # Props for the edit form: the poll's current values, with options in the
  # same {date, time, duration_minutes} shape the form submits.
  module EditProps
    private

    def edit_props(values = nil)
      {
        poll: {
          id: poll.to_param,
          name: poll.name,
          path: Rails.application.routes.url_helpers.poll_path(poll)
        },
        values: values || current_values,
        submit_path: Rails.application.routes.url_helpers.update_poll_admin_path(poll, token: poll.admin_token),
        admin_path: admin_path,
        time_zone: poll.time_zone
      }
    end

    def current_values
      {
        event: poll.name,
        description: poll.description.to_s,
        end_voting_at: poll.end_voting_at.in_time_zone(poll.zone).to_date.iso8601,
        options: poll.options.map { option_input(it) }
      }
    end

    def option_input(option)
      if option.duration_minutes >= Poll::OptionsInput::ALL_DAY
        {date: option.start.utc.to_date.iso8601, time: "", duration_minutes: option.duration_minutes}
      else
        local = option.start.in_time_zone(poll.zone)
        {date: local.to_date.iso8601, time: local.strftime("%H:%M"), duration_minutes: option.duration_minutes}
      end
    end
  end
end
