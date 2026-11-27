# frozen_string_literal: true

# Serializes a poll and its options for the voting pages.
class PollProps
  def self.call(...)
    new(...).call
  end

  def initialize(poll)
    self.poll = poll
  end

  def call
    {
      id: poll.to_param,
      name: poll.name,
      description: poll.description,
      organizer_name: poll.organizer_name,
      end_voting_at: poll.end_voting_at,
      path: routes.poll_path(poll),
      options: poll.options.map do |option|
        {
          id: option.to_param,
          start: option.start,
          duration_minutes: option.duration_minutes
        }
      end
    }
  end

  private

  attr_accessor :poll

  def routes
    Rails.application.routes.url_helpers
  end
end
