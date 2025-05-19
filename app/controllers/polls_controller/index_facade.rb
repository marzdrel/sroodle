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
      polls = fetch_polls

      Result.new(
        success?: true,
        data: {
          polls: polls.map { |poll| poll_to_hash(poll) },
        },
        errors: {},
      )
    end

    private

    attr_accessor :params

    def fetch_polls
      Poll.includes(:creator).order(created_at: :desc)
    end

    def poll_to_hash(poll)
      {
        id: poll.id,
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
