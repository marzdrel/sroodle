# frozen_string_literal: true

FacadeResult =
  Data.define(:success?, :data, :errors) do
    def props
      data.merge(
        new_poll_path: routes.new_poll_path,
        errors: errors
      )
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
