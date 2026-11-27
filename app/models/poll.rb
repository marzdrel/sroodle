# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20261127160000
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
#  time_zone       :string           default("UTC"), not null
#  closed_at       :datetime
#  final_option_id :integer
#
# Indexes
#
#  index_polls_on_admin_token      (admin_token) UNIQUE
#  index_polls_on_eid              (eid) UNIQUE
#  index_polls_on_final_option_id  (final_option_id)
#
# Foreign Keys
#
#  final_option_id  (final_option_id => poll_options.id) ON DELETE => nullify
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

  belongs_to :final_option, class_name: "Poll::Option", optional: true

  accepts_nested_attributes_for :options

  validates :name, presence: true, length: {minimum: 5, maximum: 100}
  validates :organizer_name, presence: true, length: {minimum: 2, maximum: 50}

  validates(
    :organizer_email,
    format: {with: URI::MailTo::EMAIL_REGEXP},
    allow_blank: true
  )

  validates :end_voting_at, presence: true
  validate :time_zone_exists

  def to_param = exid_value

  validate :final_option_belongs_to_poll

  def voting_open?
    !closed? && end_voting_at.future?
  end

  def closed? = closed_at.present?

  # Ends voting and records the chosen date.
  def close!(option)
    update!(closed_at: Time.current, final_option: option)
  end

  def reopen!
    update!(closed_at: nil, final_option: nil)
  end

  def zone
    ActiveSupport::TimeZone[time_zone.to_s] || ActiveSupport::TimeZone["UTC"]
  end

  def admin_token?(candidate)
    candidate.present? &&
      ActiveSupport::SecurityUtils.secure_compare(admin_token, candidate.to_s)
  end

  private

  def final_option_belongs_to_poll
    return if final_option.nil? || final_option.poll_id == id

    errors.add(:final_option, "must be one of this poll's options")
  end

  def time_zone_exists
    return if ActiveSupport::TimeZone[time_zone.to_s]

    errors.add(:time_zone, "is not a known time zone")
  end
end
