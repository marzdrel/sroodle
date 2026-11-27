# frozen_string_literal: true

class AdminsController
  class ShowFacade
    include FindPoll

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
            admin: routes.poll_admin_url(poll, token: poll.admin_token, host: request.base_url)
          },
          participants_count: poll.participants.size,
          options: results.serialized_options,
          best_option_ids: results.best_options.map(&:to_param),
          closed: poll.closed?,
          voting_open: poll.voting_open?,
          final_option_id: poll.final_option&.to_param,
          close_path: routes.close_poll_admin_path(poll, token: poll.admin_token),
          reopen_path: routes.reopen_poll_admin_path(poll, token: poll.admin_token)
        }
      )
    end

    private

    attr_accessor :params, :cookies, :request

    def poll_scope
      Poll.includes(:options, :final_option, participants: :votes)
    end

    def results
      @_results ||= PollResults.new(poll)
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
