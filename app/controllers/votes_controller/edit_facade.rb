# frozen_string_literal: true

class VotesController
  class EditFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, cookies)
      self.params = params
      self.cookies = cookies
    end

    # Fails when this browser has not answered the poll yet.
    def call
      FacadeResult.new(
        success?: participant.present?,
        data: participant ? data : {}
      )
    end

    private

    attr_accessor :params, :cookies

    def data
      {
        poll: PollProps.call(poll),
        vote: {
          name: participant.name,
          email: participant.email.to_s,
          responses: responses
        },
        submit_path: routes.update_poll_votes_path(poll),
        edit_link: routes.participant_link_path(poll, token: participant.token)
      }
    end

    def responses
      participant
        .votes
        .includes(:option)
        .to_h { [it.option.to_param, it.response] }
    end

    def poll
      @_poll ||= Poll.includes(:options).exid_loader(params.fetch(:id))
    end

    def participant
      @_participant ||= PollSession.new(poll, cookies).participant
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
