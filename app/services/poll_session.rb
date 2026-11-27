# frozen_string_literal: true

# Remembers, per poll, which participant and whether the organizer is using
# this browser. Both are stored in signed, permanent, HTTP-only cookies, so
# nobody needs an account.
class PollSession
  def initialize(poll, cookies)
    self.poll = poll
    self.cookies = cookies
  end

  def participant
    token = cookies.signed[participant_key]
    return if token.blank?

    @_participant ||= poll.participants.find_by(token: token)
  end

  def remember_participant(participant)
    write(participant_key, participant.token)
  end

  def admin?
    poll.admin_token?(cookies.signed[admin_key])
  end

  def remember_admin
    write(admin_key, poll.admin_token)
  end

  private

  attr_accessor :poll, :cookies

  def participant_key = "sroodle_participant_#{poll.eid}"

  def admin_key = "sroodle_admin_#{poll.eid}"

  def write(key, value)
    cookies.signed.permanent[key] = {
      value: value,
      httponly: true,
      same_site: :lax
    }
  end
end
