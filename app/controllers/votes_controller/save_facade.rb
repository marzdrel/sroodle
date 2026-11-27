# frozen_string_literal: true

class VotesController
  # Creates or updates the answers of the participant using this browser.
  #
  # mode: :create always adds a new participant, unless this browser already
  #       answered (then it updates their answers instead of duplicating them)
  # mode: :update requires an existing participant
  class SaveFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, cookies, mode:)
      self.params = params
      self.cookies = cookies
      self.mode = mode
    end

    def call
      return missing_participant if mode == :update && session.participant.nil?

      if form.save
        session.remember_participant(form.participant)
      end

      FacadeResult.new(
        success?: form.errors.empty?,
        errors: errors,
        data: data
      )
    end

    private

    attr_accessor :params, :cookies, :mode

    def missing_participant
      FacadeResult.new(success?: false, data: {participant_missing: true})
    end

    def form
      @_form ||= Poll::Vote::Form.new(
        strong_params,
        poll: poll,
        participant: session.participant
      )
    end

    def data
      {
        poll: PollProps.call(poll),
        vote: {
          name: form.name.to_s,
          email: form.email.to_s,
          responses: form.responses.to_h
        },
        submit_path: submit_path
      }
    end

    def submit_path
      if session.participant
        routes.update_poll_votes_path(poll)
      else
        routes.poll_votes_path(poll)
      end
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
      params.expect(vote: [:name, :email, {responses: {}}])
    end

    def poll
      @_poll ||= Poll.includes(:options).exid_loader(params.fetch(:id))
    end

    def session
      @_session ||= PollSession.new(poll, cookies)
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
