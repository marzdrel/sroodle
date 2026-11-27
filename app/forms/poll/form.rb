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
    attribute :end_voting_at, :string
    attribute :dates, default: []

    attr_reader :poll

    validates :name, presence: true, length: {minimum: 2, maximum: 50}
    validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true
    validates :event, presence: true, length: {minimum: 5, maximum: 100}
    validates :end_voting_at, presence: true
    validate :at_least_two_dates
    validate :dates_are_valid

    def save
      return false unless valid?

      @poll = Poll.create!(
        name: event,
        description: description,
        organizer_name: name,
        organizer_email: email.presence,
        end_voting_at: end_voting_date,
        options_attributes: options_attributes
      )

      true
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)

      false
    end

    private

    def at_least_two_dates
      return if dates.is_a?(Array) && dates.uniq.length >= 2

      errors.add(:dates, "must include at least 2 dates for voting")
    end

    def dates_are_valid
      return unless dates.is_a?(Array)

      parsed_dates
    rescue Date::Error
      errors.add(:dates, "contains invalid date format")
    end

    def parsed_dates
      dates.uniq.map { Date.iso8601(it) }
    end

    def options_attributes
      parsed_dates.sort.map do
        {
          start: it.beginning_of_day,
          duration_minutes: 1440
        }
      end
    end

    def end_voting_date
      Time.zone.parse(end_voting_at).end_of_day
    end
  end
end
