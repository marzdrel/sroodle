# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20250519211503
#
# Table name: polls
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :string
#  creator_id  :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  eid         :uuid             not null
#
# Indexes
#
#  index_polls_on_creator_id  (creator_id)
#  index_polls_on_eid         (eid) UNIQUE
#
# Foreign Keys
#
#  creator_id  (creator_id => users.id)
#
# rubocop:enable Layout/LineLength

class Poll < ApplicationRecord
  include Exid::Record.new("poll", :eid)

  belongs_to :creator, class_name: "User"

  validates(
    :name,
    presence: true,
    length: {minimum: 5, maximum: 100}
  )

  def to_param = exid_value
end
