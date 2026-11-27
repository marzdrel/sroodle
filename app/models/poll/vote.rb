# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20261127140000
#
# Table name: poll_votes
#
#  id             :integer          not null, primary key
#  poll_id        :integer          not null
#  option_id      :integer          not null
#  response       :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  eid            :text
#  participant_id :integer          not null
#
# Indexes
#
#  index_poll_votes_on_eid                 (eid) UNIQUE
#  index_poll_votes_on_option_id           (option_id)
#  index_poll_votes_on_option_participant  (option_id,participant_id) UNIQUE
#  index_poll_votes_on_participant_id      (participant_id)
#  index_poll_votes_on_poll_id             (poll_id)
#
# Foreign Keys
#
#  option_id       (option_id => poll_options.id)
#  participant_id  (participant_id => poll_participants.id)
#  poll_id         (poll_id => polls.id)
#
# rubocop:enable Layout/LineLength

class Poll
  class Vote < ApplicationRecord
    include Exid::Record.new("vote", :eid)
    include GeneratesEid

    self.table_name = "poll_votes"

    belongs_to :poll
    belongs_to :option, class_name: "Poll::Option"
    belongs_to :participant, class_name: "Poll::Participant"

    RESPONSES = %w[yes maybe no].freeze

    validates :response, inclusion: {in: RESPONSES}

    def to_param = exid_value
  end
end
