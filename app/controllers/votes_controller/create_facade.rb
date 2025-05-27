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
          poll: serialized_poll
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
