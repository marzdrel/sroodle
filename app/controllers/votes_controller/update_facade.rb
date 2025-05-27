# frozen_string_literal: true

class VotesController
  class UpdateFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      update_votes

      FacadeResult.new(
        errors: errors,
        success?: form_valid?,
        data: {
          poll: serialized_poll,
          vote: serialized_vote
        }
      )
    end

    private

    attr_accessor :params

    def form_valid?
      validate_responses && user.present?
    end

    def validate_responses
      @_validation_errors = {}

      # Check that all poll options have responses
      poll_option_ids = poll.options.map(&:exid_value)
      response_option_ids = vote_params[:responses].keys.map(&:to_s)

      missing_responses = poll_option_ids - response_option_ids
      if missing_responses.any?
        @_validation_errors[:responses] = "Must include a response for all proposed dates"
      end

      # Check that all responses are valid
      invalid_responses = vote_params[:responses].values.reject { |value| %w[yes maybe no].include?(value) }
      if invalid_responses.any?
        @_validation_errors[:responses] = "Must be 'yes', 'maybe', or 'no'"
      end

      # Check name and email
      if vote_params[:name].blank?
        @_validation_errors[:name] = "Name can't be blank"
      end

      if vote_params[:email].blank?
        @_validation_errors[:email] = "Email can't be blank"
      elsif !vote_params[:email].match?(URI::MailTo::EMAIL_REGEXP)
        @_validation_errors[:email] = "Email is not a valid email address"
      end

      @_validation_errors.empty?
    end

    def errors
      @_validation_errors || {}
    end

    def update_votes
      return false unless form_valid?

      ActiveRecord::Base.transaction do
        # Update user email if it changed
        if user.email != vote_params[:email]
          # Check if another user already has this email
          existing_user = User.find_by(email: vote_params[:email])
          if existing_user && existing_user.id != user.id
            @_validation_errors = {email: "Email is already taken"}
            return false
          end
          user.update!(email: vote_params[:email])
        end

        # Update all vote responses
        vote_params[:responses].each do |option_eid, response|
          option = poll.options.exid_loader(option_eid)
          vote = user.votes.find_by(poll: poll, option: option)

          if vote
            vote.update!(response: response)
          else
            user.votes.create!(poll: poll, option: option, response: response)
          end
        end
      end

      true
    rescue ActiveRecord::RecordInvalid => e
      @_validation_errors = {base: e.message}
      false
    end

    def vote_params
      @_vote_params ||= params.expect(vote: [:name, :email, {responses: {}}])[:vote]
    end

    def user_id
      params.fetch(:id)
    end

    def user
      @_user ||= User.find_by(id: user_id)
    end

    def poll
      @_poll ||= Poll.includes(:options, :votes).exid_loader(params.fetch(:poll_id))
    end

    def user_votes
      @_user_votes ||= poll&.votes&.joins(:user)&.where(users: {id: user_id})
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
      return {} unless user

      # Reload user votes after update
      updated_votes = user.votes.where(poll: poll).includes(:option)
      responses = updated_votes.each_with_object({}) do |vote, hash|
        hash[vote.option.to_param] = vote.response
      end

      {
        id: user.id.to_s,
        name: vote_params[:name] || user.email.split("@").first.humanize,
        email: user.email,
        responses: responses
      }
    end
  end
end
