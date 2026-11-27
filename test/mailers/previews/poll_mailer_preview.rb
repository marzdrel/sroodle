# Preview at /rails/mailers/poll_mailer in development.
class PollMailerPreview < ActionMailer::Preview
  def created
    PollMailer.with(poll: Poll.where.not(organizer_email: nil).last || Poll.last).created
  end

  def final_date
    poll = Poll.where.not(final_option_id: nil).last || Poll.last
    poll.final_option ||= poll.options.first
    participant = poll.participants.first || poll.participants.build(name: "Dave", email: "dave@example.com")

    PollMailer.with(poll: poll, participant: participant).final_date
  end
end
