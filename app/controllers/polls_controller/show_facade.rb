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
          options: serialized_options,
          participants: serialized_participants,
          best_option_ids: best_option_ids,
          you_voted: current_participant.present?,
          voting_open: poll.voting_open?,
          admin_path: admin_path
        }
      )
    end

    private

    attr_accessor :params, :cookies

    def poll
      @_poll ||= Poll.includes(:options, participants: :votes).exid_loader(params.fetch(:id))
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

    def serialized_options
      poll.options.map do |option|
        {
          id: option.to_param,
          start: option.start,
          duration_minutes: option.duration_minutes,
          counts: counts.fetch(option.id)
        }
      end
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

    def counts
      @_counts ||=
        poll.options.to_h do |option|
          responses = all_votes.select { it.option_id == option.id }.map(&:response)

          [option.id, Poll::Vote::RESPONSES.index_with { responses.count(it) }]
        end
    end

    def all_votes
      @_all_votes ||= poll.participants.flat_map(&:votes)
    end

    # The options with the most "yes" answers, using "maybe" to break ties.
    # Empty until at least one option has a "yes" or "maybe".
    def best_option_ids
      scores = poll.options.to_h do |option|
        count = counts.fetch(option.id)
        [option, [count["yes"], count["maybe"]]]
      end

      best = scores.values.max
      return [] if best.nil? || best == [0, 0]

      scores.select { |_, score| score == best }.keys.map(&:to_param)
    end

    def routes
      Rails.application.routes.url_helpers
    end
  end
end
