# frozen_string_literal: true

class PollsController
  class CreateFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, cookies)
      self.params = params
      self.cookies = cookies
    end

    def call
      if form.save
        PollSession.new(form.poll, cookies).remember_admin
      end

      FacadeResult.new(
        success?: form.poll.present?,
        errors: errors,
        data: data
      )
    end

    private

    attr_accessor :params, :cookies

    def form
      @_form ||= Poll::Form.new(strong_params)
    end

    def data
      if form.poll
        {admin_path: routes.poll_admin_path(form.poll, token: form.poll.admin_token)}
      else
        {poll: strong_params.to_h.except("dates")}
      end
    end

    def errors
      form
        .errors
        .to_hash
        .transform_values(&:to_sentence)
        .to_h do |name, desc|
          [
            name,
            [name.capitalize, desc].join(" ")
          ]
        end
    end

    def strong_params
      params.expect(
        poll: [
          :name,
          :email,
          :description,
          :event,
          :end_voting_at,
          {
            dates: []
          }
        ]
      )
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
