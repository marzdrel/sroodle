# frozen_string_literal: true

class VotesController
  class EditFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, current_user)
      self.params = params
      self.current_user = current_user
    end

    def call
      FacadeResult.new(
        success?: user_votes.present?,
        current_user: current_user,
        data: {
          poll: serialized_poll,
          votes: serialized_votes
        },
        errors: []
      )
    end

    private

    attr_accessor :params, :current_user

    def poll
      @_poll ||= Poll.includes(:options, :votes).exid_loader(params.fetch(:id))
    end

    def user_votes
      @_user_votes ||= poll.votes.joins(:user).where(users: {id: current_user.id})
    end

    def user
      current_user
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

    def serialized_votes
      responses = user_votes.to_h do |vote|
        [vote.option.to_param, vote.response]
      end

      {
        name: user.email,
        email: user.email,
        responses: responses
      }
    end
  end
end
