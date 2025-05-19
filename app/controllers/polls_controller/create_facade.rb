# frozen_string_literal: true

class PollsController
  class CreateFacade
    Result = Data.define(:success?, :data, :errors)

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      form.valid?

      Result.new(
        errors: errors,
        success?: form.valid?,
        data: {},
      )
    end

    private

    attr_accessor :params

    def form
      @_form ||= PollForm.new(strong_params)
    end

    def errors
      poll.errors.to_hash.transform_values(&:to_sentence)
    end

    def poll
      @_poll ||= Poll.new(poll_strong_params)
    end

    def strong_params
      params.require(:poll).expect(:name, :email, :description, :event)
    end
  end
end
