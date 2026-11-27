# rubocop:disable Layout/LineLength
# == Schema Information
#
# Table name: polls
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  description     :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  end_voting_at   :datetime         not null
#  eid             :text
#  admin_token     :string           not null
#  organizer_name  :string           not null
#  organizer_email :string
#
# Indexes
#
#  index_polls_on_admin_token  (admin_token) UNIQUE
#  index_polls_on_eid          (eid) UNIQUE
#
# rubocop:enable Layout/LineLength

class Poll < ApplicationRecord
  include Exid::Record.new("poll", :eid)
  include GeneratesEid

  has_secure_token :admin_token, length: 24

  has_many(
    :options,
    -> { order(:start) },
    class_name: "Poll::Option",
    dependent: :destroy,
    inverse_of: :poll
  )

  has_many(
    :participants,
    -> { order(:created_at, :id) },
    class_name: "Poll::Participant",
    dependent: :destroy,
    inverse_of: :poll
  )

  has_many :votes, class_name: "Poll::Vote", dependent: :delete_all

  accepts_nested_attributes_for :options

  validates :name, presence: true, length: {minimum: 5, maximum: 100}
  validates :organizer_name, presence: true, length: {minimum: 2, maximum: 50}

  validates(
    :organizer_email,
    format: {with: URI::MailTo::EMAIL_REGEXP},
    allow_blank: true
  )

  validates :end_voting_at, presence: true

  def to_param = exid_value

  def admin_token?(candidate)
    candidate.present? &&
      ActiveSupport::SecurityUtils.secure_compare(admin_token, candidate.to_s)
  end
end
