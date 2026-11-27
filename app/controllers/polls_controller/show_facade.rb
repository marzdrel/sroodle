# frozen_string_literal: true

class PollsController
  # The public results page: every participant's answers and the totals per
  # option. Emails are never included, only the names people chose to show.
  class ShowFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, cookies)
      self.params = params
      self.cookies = cookies
    end

    def call
      FacadeResult.new(
        success?: true,
        data: {
          poll: serialized_poll,
          options: results.serialized_options,
          participants: serialized_participants,
          best_option_ids: results.best_options.map(&:to_param),
          you_voted: current_participant.present?,
          voting_open: poll.voting_open?,
          final_option_id: poll.final_option&.to_param,
          calendar_path: (routes.poll_calendar_path(poll) if poll.final_option),
          admin_path: admin_path
        }
      )
    end

    private

    attr_accessor :params, :cookies

    def poll
      @_poll ||= Poll.includes(:options, :final_option, participants: :votes).exid_loader(params.fetch(:id))
    end

    def session
      @_session ||= PollSession.new(poll, cookies)
    end

    # Only for the organizer's own browser (it visited the admin link).
    def admin_path
      return unless session.admin?

      routes.poll_admin_path(poll, token: poll.admin_token)
    end

    def current_participant
      @_current_participant ||= session.participant
    end

    def serialized_poll
      {
        id: poll.to_param,
        name: poll.name,
        description: poll.description,
        organizer_name: poll.organizer_name,
        created_at: poll.created_at,
        end_voting_at: poll.end_voting_at,
        path: routes.poll_path(poll),
        vote_path: routes.new_poll_vote_path(poll),
        edit_vote_path: routes.edit_poll_vote_path(poll)
      }
    end

    def serialized_participants
      poll.participants.map do |participant|
        {
          id: participant.to_param,
          name: participant.name,
          you: participant == current_participant,
          responses: participant.votes.to_h do |vote|
            [option_eids.fetch(vote.option_id), vote.response]
          end
        }
      end
    end

    def option_eids
      @_option_eids ||= poll.options.to_h { [it.id, it.to_param] }
    end

    def results
      @_results ||= PollResults.new(poll)
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
