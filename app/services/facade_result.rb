# frozen_string_literal: true

FacadeResult =
  Data.define(:success?, :data, :errors, :current_user) do
    def props
      data.merge(
        new_poll_path: routes.new_poll_path,
        errors: errors,
        logged_in: current_user.present?
      )
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
