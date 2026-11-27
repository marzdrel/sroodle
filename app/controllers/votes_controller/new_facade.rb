# frozen_string_literal: true

class VotesController
  class NewFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, cookies)
      self.params = params
      self.cookies = cookies
    end

    # Fails when this browser already answered the poll, so the controller
    # can send the participant to their edit page instead.
    def call
      FacadeResult.new(
        success?: session.participant.nil?,
        data: {
          poll: PollProps.call(poll),
          vote: {name: "", email: "", responses: {}},
          submit_path: routes.poll_votes_path(poll)
        }
      )
    end

    private

    attr_accessor :params, :cookies

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
