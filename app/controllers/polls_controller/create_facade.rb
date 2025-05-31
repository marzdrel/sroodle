# frozen_string_literal: true

class PollsController
  class CreateFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, current_user)
      self.params = params
      self.current_user = current_user
    end

    def call
      form.save

      FacadeResult.new(
        errors: errors,
        success?: form.valid?,
        current_user: current_user,
        data: {}
      )
    end

    private

    attr_accessor :params, :current_user

    def form
      @_form ||= Poll::Form.new(strong_params)
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
          {
            dates: []
          }
        ]
      )
    end
  end
end
