# frozen_string_literal: true

class VotesController
  class NewFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, current_user)
      self.params = params
      self.current_user = current_user
    end

    def call
      FacadeResult.new(
        success?: poll.present?,
        data: {
          poll: serialized_poll
        },
        errors: []
      )
    end

    private

    attr_accessor :params, :current_user

    def poll
      @_poll ||= Poll.includes(:options, :votes).exid_loader(params.fetch(:id))
    end

    def serialized_poll
      {
        id: poll.to_param,
        name: poll.name,
        description: poll.description,
        options: poll.options.map do |option|
          {
            id: option.to_param,
            start: option.start,
            duration_minutes: option.duration_minutes
          }
        end
      }
    end
  end
end
