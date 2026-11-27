# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: poll_participants
#
#  id         :integer          not null, primary key
#  poll_id    :integer          not null
#  name       :string           not null
#  email      :string
#  token      :string           not null
#  eid        :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_poll_participants_on_eid      (eid) UNIQUE
#  index_poll_participants_on_poll_id  (poll_id)
#  index_poll_participants_on_token    (token) UNIQUE
#
# Foreign Keys
#
#  poll_id  (poll_id => polls.id)
#
# rubocop:enable Layout/LineLength

class Poll
  # Someone who answered a poll. They are identified by a secret token kept in
  # a signed cookie and in their personal edit link, not by an account.
  class Participant < ApplicationRecord
    include Exid::Record.new("part", :eid)
    include GeneratesEid

    self.table_name = "poll_participants"

    has_secure_token :token, length: 24

    belongs_to :poll

    has_many(
      :votes,
      class_name: "Poll::Vote",
      dependent: :delete_all,
      inverse_of: :participant
    )

    validates :name, presence: true, length: {minimum: 2, maximum: 50}

    validates(
      :email,
      format: {with: URI::MailTo::EMAIL_REGEXP},
      allow_blank: true
    )

    def to_param = exid_value
  end
end
