# frozen_string_literal: true

# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20250524134301
#
# Table name: poll_votes
#
#  id         :integer          not null, primary key
#  poll_id    :integer          not null
#  option_id  :integer          not null
#  user_id    :integer          not null
#  response   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_poll_votes_on_option_id         (option_id)
#  index_poll_votes_on_poll_id           (poll_id)
#  index_poll_votes_on_poll_option_user  (poll_id,option_id,user_id) UNIQUE
#  index_poll_votes_on_user_id           (user_id)
#
# Foreign Keys
#
#  option_id  (option_id => options.id)
#  poll_id    (poll_id => polls.id)
#  user_id    (user_id => users.id)
#
# rubocop:enable Layout/LineLength

class Poll
  class Vote < ApplicationRecord
    belongs_to :poll
    belongs_to :option
    belongs_to :user
  end
end
