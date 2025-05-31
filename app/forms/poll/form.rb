# frozen_string_literal: true

class Poll
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :name, :string
    attribute :email, :string
    attribute :event, :string
    attribute :description, :string
    attribute :end_voting_at, :datetime
    attribute :dates, default: []

    validates :name, presence: true, length: {minimum: 2, maximum: 50}
    validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
    validates :event, presence: true, length: {minimum: 5, maximum: 100}
    validates :description, presence: false
    validates :end_voting_at, presence: true
    validate :at_least_two_dates

    def at_least_two_dates
      return if dates.is_a?(Array) && dates.length >= 2

      errors.add(:dates, "must include at least 2 dates for voting")
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        user = find_or_create_user
        create_poll(user)
      end

      true
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)

      false
    end

    private

    def options_attributes
      dates.map do
        {
          start: Date.parse(it).beginning_of_day,
          duration_minutes: 1440,
          eid: UUID7.generate
        }
      end
    rescue Date::Error
      errors.add(:dates, "contains invalid date format")
    end

    private

    def find_or_create_user
      user = User.find_by(email: email)
      return user if user

      password = SecureRandom.hex(8)
      User.create!(email:, password:, status: "pending")
    end

    def create_poll(user)
      Poll.create!(
        name: event,
        description: description,
        creator: user,
        eid: UUID7.generate,
        end_voting_at: end_voting_at,
        options_attributes: options_attributes
      )
    end
  end
end
