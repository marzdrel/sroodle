# frozen_string_literal: true

class PollsController
  class CreateFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      form.save

      Result.new(
        errors: errors,
        success?: form.valid?,
        data: {},
      )
    end

    private

    attr_accessor :params

    def form
      @_form ||= Poll::Form.new(strong_params)
    end

    def errors
      form.errors.to_hash.transform_values(&:to_sentence)
    end

    def strong_params
      params.expect(poll: [:name, :email, :description, :event])
    end
  end
end
