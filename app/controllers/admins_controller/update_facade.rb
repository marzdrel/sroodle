# frozen_string_literal: true

class AdminsController
  class UpdateFacade
    include FindPoll
    include EditProps

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      success = form.save

      FacadeResult.new(
        success?: success,
        errors: errors,
        data: edit_props(success ? nil : submitted_values)
      )
    end

    private

    attr_accessor :params

    def poll_scope = Poll.includes(:options)

    def form
      @_form ||= Poll::UpdateForm.new(strong_params, poll: poll)
    end

    def submitted_values
      strong_params.to_h.symbolize_keys
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
      @_strong_params ||= params.expect(
        poll: [
          :event,
          :description,
          :end_voting_at,
          {options: [[:date, :time, :duration_minutes]]}
        ]
      )
    end
  end
end
