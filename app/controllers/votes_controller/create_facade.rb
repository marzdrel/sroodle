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
      form.save

      FacadeResult.new(
        errors: errors,
        success?: form.valid?,
        data: {
          votes: form.votes,
          poll: poll_with_votes
        }
      )
    end

    private

    attr_accessor :params

    def form
      @_form ||= Poll::Vote::Form.new(strong_params)
    end

    def errors
      form
        .errors
        .to_hash
        .transform_values(&:to_sentence)
        .to_h do |name, desc|
          [
            name,
            [name.capitalize, desc].join(" ")
          ]
        end
    end

    def strong_params
      params
        .expect(vote: [:name, :email, {responses: {}}])
        .merge(poll_id: params.fetch(:poll_id))
    end

    def poll_with_votes
      poll_with_includes = Poll.includes(:options, :votes).exid_loader(params.fetch(:poll_id))

      {
        id: poll_with_includes.to_param,
        name: poll_with_includes.name,
        description: poll_with_includes.description,
        options: poll_with_includes.options.map do |option|
          {
            id: option.id,
            start: option.start,
            duration_minutes: option.duration_minutes,
            votes_count: option.votes.count
          }
        end
      }
    end
  end
end
