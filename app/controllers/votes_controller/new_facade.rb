# frozen_string_literal: true

class VotesController
  class NewFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      FacadeResult.new(
        success?: poll.present?,
        data: poll ? serialize_poll_for_voting(poll) : {},
        errors: poll.present? ? [] : ["Poll not found"]
      )
    end

    private

    attr_accessor :params

    def poll
      @_poll ||= Poll.includes(:options).find_by(id: params[:poll_id])
    end

    def serialize_poll_for_voting(poll)
      {
        poll: {
          id: poll.id,
          name: poll.name,
          description: poll.description,
          event: poll.event,
          options: poll.options.map do |option|
            {
              id: option.id,
              start: option.start,
              duration_minutes: option.duration_minutes
            }
          end
        }
      }
    end
  end
end
