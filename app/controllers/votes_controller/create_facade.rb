# frozen_string_literal: true

class VotesController
  class CreateFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      vote = create_vote

      FacadeResult.new(
        errors: vote&.errors&.full_messages || [],
        success?: vote&.persisted? || false,
        data: {
          vote: vote,
          poll: poll_with_votes
        }
      )
    end

    private

    attr_accessor :params

    def create_vote
      return nil unless poll && poll_option

      poll.votes.create(
        option: poll_option,
        user: current_user,
        response: "yes"
      )
    end

    def poll
      @_poll ||= Poll.find_by(id: params[:poll_id])
    end

    def poll_option
      @_poll_option ||= poll&.options&.find_by(id: params[:poll_option_id])
    end

    def current_user
      # For now, create anonymous user or use session-based identification
      User.first || User.create!(name: "Anonymous", email: "anonymous@example.com")
    end

    def poll_with_votes
      return nil unless poll

      poll_with_includes = Poll.includes(:options, :votes).find(poll.id)
      {
        id: poll_with_includes.id,
        name: poll_with_includes.name,
        description: poll_with_includes.description,
        event: poll_with_includes.event,
        dates: poll_with_includes.dates,
        options: poll_with_includes.options.map do |option|
          {
            id: option.id,
            name: option.name,
            votes_count: option.votes.count
          }
        end
      }
    end
  end
end
