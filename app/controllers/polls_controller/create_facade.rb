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
      poll.valid?

      Result.new(
        errors: errors,
        success?: poll.valid?,
        data: {},
      )
    end

    private

    attr_accessor :params

    def errors
      poll.errors.to_hash.transform_values(&:to_sentence)
    end

    def poll
      @_poll ||= Poll.new(poll_strong_params)
    end

    def poll_strong_params
      {
        name: params.fetch(:event),
        description: params.fetch(:description),
      }
    end

    def strong_params
      # params.require(:poll).expect(:name, :email, :description)
    end
  end
end
