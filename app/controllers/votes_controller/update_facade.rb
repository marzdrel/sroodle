# frozen_string_literal: true

class VotesController
  class UpdateFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, current_user)
      self.params = params
      self.current_user = current_user
    end

    def call
      # raise ArgumentError, params
      # Delete existing votes for this user and poll, then create new ones
      delete_existing_votes if form.valid?

      # Use CreateFacade logic to create new votes
      create_result = create_facade.call

      FacadeResult.new(
        errors: create_result.errors,
        success?: create_result.success?,
        current_user: current_user,
        data: {
          poll: create_result.data[:poll],
          vote: serialized_vote
        }
      )
    end

    private

    attr_accessor :params, :current_user

    def form
      @_form ||= Poll::Vote::Form.new(strong_params, current_user:)
    end

    def delete_existing_votes
      current_user.votes.where(poll: poll).destroy_all
    end

    def create_facade
      @_create_facade ||= CreateFacade.new(create_params, current_user)
    end

    def create_params
      ActionController::Parameters.new({
        poll_id: params.fetch(:id),
        vote: vote_params
      })
    end

    def vote_params
      params.expect(vote: [:name, :email, {responses: {}}])
    end

    def strong_params
      params
        .expect(vote: [:name, :email, {responses: {}}])
        .merge(poll_id: params.fetch(:id))
    end

    def poll
      @_poll ||= Poll.includes(:options, :votes).exid_loader(params.fetch(:id))
    end

    def serialized_vote
      return {} unless current_user

      # Get updated votes after creation
      updated_votes = current_user.votes.where(poll: poll).includes(:option)
      responses = updated_votes.each_with_object({}) do |vote, hash|
        hash[vote.option.to_param] = vote.response
      end

      {
        name: vote_params[:name],
        email: vote_params[:email],
        responses: responses
      }
    end
  end
end
