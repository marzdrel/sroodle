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
        success?: poll.present? && user_votes.present?,
        current_user: current_user,
        data: {
          poll: serialized_poll,
          vote: serialized_vote
        },
        errors: []
      )
    end

    private

    attr_accessor :params, :current_user

    def poll
      @_poll ||= Poll.includes(:options, :votes).exid_loader(params.fetch(:poll_id))
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

    def serialized_vote
      return {} unless user && user_votes.present?

      responses = user_votes.includes(:option).each_with_object({}) do |vote, hash|
        hash[vote.option.to_param] = vote.response
      end

      {
        id: user.id.to_s,
        name: user.email.split("@").first.humanize, # Fallback name from email
        email: user.email,
        responses: responses
      }
    end
  end
end
