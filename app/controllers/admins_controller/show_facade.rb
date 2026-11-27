# frozen_string_literal: true

class AdminsController
  class ShowFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, cookies, request)
      self.params = params
      self.cookies = cookies
      self.request = request
    end

    def call
      PollSession.new(poll, cookies).remember_admin

      FacadeResult.new(
        success?: true,
        data: {
          poll: PollProps.call(poll),
          links: {
            public: routes.poll_url(poll, host: request.base_url),
            vote: routes.new_poll_vote_url(poll, host: request.base_url),
            admin: request.original_url
          },
          participants_count: poll.participants.count
        }
      )
    end

    private

    attr_accessor :params, :cookies, :request

    def poll
      @_poll ||= find_poll
    end

    # Raises RecordNotFound (404) for a wrong token, the same as for an
    # unknown poll, so the response doesn't reveal which part was wrong.
    def find_poll
      poll = Poll.includes(:options).exid_loader(params.fetch(:id))
      raise ActiveRecord::RecordNotFound unless poll.admin_token?(params[:token])

      poll
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
