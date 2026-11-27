# frozen_string_literal: true

# Totals per option and the best options of a poll. Expects the poll to be
# loaded with `includes(:options, participants: :votes)`.
class PollResults
  def initialize(poll)
    self.poll = poll
  end

  # {option_id => {"yes" => 2, "maybe" => 0, "no" => 1}}
  def counts
    @_counts ||=
      poll.options.to_h do |option|
        responses = votes.select { it.option_id == option.id }.map(&:response)

        [option.id, Poll::Vote::RESPONSES.index_with { responses.count(it) }]
      end
  end

  # The options with the most "yes" answers, using "maybe" to break ties.
  # Empty until at least one option has a "yes" or "maybe".
  def best_options
    scores = poll.options.to_h do |option|
      count = counts.fetch(option.id)
      [option, [count["yes"], count["maybe"]]]
    end

    best = scores.values.max
    return [] if best.nil? || best == [0, 0]

    scores.select { |_, score| score == best }.keys
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

  private

  attr_accessor :poll

  def votes
    @_votes ||= poll.participants.flat_map(&:votes)
  end
end
