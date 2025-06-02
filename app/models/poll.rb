# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20250602135050
#
# Table name: polls
#
#  id            :integer          not null, primary key
#  name          :string           not null
#  description   :string
#  creator_id    :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  end_voting_at :datetime         not null
#  eid           :text
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
  has_many :options, class_name: "Poll::Option", dependent: :destroy
  has_many :votes, class_name: "Poll::Vote", dependent: :destroy

  accepts_nested_attributes_for :options

  validates(
    :name,
    presence: true,
    length: {minimum: 5, maximum: 100}
  )

  validates :end_voting_at, presence: true

  def to_param = exid_value
end
