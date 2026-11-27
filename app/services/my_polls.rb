# frozen_string_literal: true

# The polls this browser created or answered, found through the per-poll
# cookies set by PollSession. Nothing here can list anyone else's polls.
class MyPolls
  LIMIT = 20

  def initialize(cookies)
    self.cookies = cookies
  end

  def call
    polls.filter_map { serialize(it) }.first(LIMIT)
  end

  private

  attr_accessor :cookies

  def polls
    eids = cookies.to_h.keys.filter_map { it[PollSession::COOKIE_EID, 1] }.uniq
    return [] if eids.empty?

    Poll.where(eid: eids).order(created_at: :desc).limit(LIMIT * 2)
  end

  def serialize(poll)
    session = PollSession.new(poll, cookies)
    organizer = session.admin?
    participant = session.participant
    return unless organizer || participant

    {
      id: poll.to_param,
      name: poll.name,
      path: routes.poll_path(poll),
      admin_path: (routes.poll_admin_path(poll, token: poll.admin_token) if organizer),
      role: organizer ? "organizer" : "participant",
      closed: !poll.voting_open?
    }
  end

  def routes
    Rails.application.routes.url_helpers
  end
end
