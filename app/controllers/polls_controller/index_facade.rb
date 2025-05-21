# frozen_string_literal: true

class PollsController
  class IndexFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      Result.new(
        success?: true,
        data: {
          polls: polls.map { serialize(it) },
        },
        errors: {},
      )
    end

    private

    attr_accessor :params

    def polls
      @_polls ||= Poll.includes(:creator).order(created_at: :desc)
    end

    def serialize(poll)
      {
        id: poll.to_param,
        name: poll.name,
        description: poll.description,
        creator: {
          email: poll.creator.email,
        },
        created_at: poll.created_at,
      }
    end
  end
end
