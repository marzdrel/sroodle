# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20250524132821
#
# Table name: poll_options
#
#  id               :integer          not null, primary key
#  poll_id          :integer          not null
#  start            :datetime         not null
#  duration_minutes :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_poll_options_on_poll_id            (poll_id)
#  index_poll_options_on_poll_id_and_start  (poll_id,start) UNIQUE
#  index_poll_options_on_start              (start) UNIQUE
#
# Foreign Keys
#
#  poll_id  (poll_id => polls.id)
#
# rubocop:enable Layout/LineLength
class Poll::Option < ApplicationRecord
  belongs_to :poll
end
