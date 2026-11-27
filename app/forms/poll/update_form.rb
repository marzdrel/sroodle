# frozen_string_literal: true

class Poll
  # Edits an existing poll: title, description, deadline and options.
  #
  # Options are matched by their start time. Options that stay keep their
  # votes (a changed duration is updated in place), removed options lose
  # their votes, and new options start without answers.
  class UpdateForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :event, :string
    attribute :description, :string
    attribute :end_voting_at, :string
    attribute :options, default: []

    validates :event, presence: true, length: {minimum: 5, maximum: 100}
    validates :end_voting_at, presence: true
    validate :end_voting_date_is_valid
    validate :options_are_valid

    attr_reader :poll

    def initialize(attributes = {}, poll:)
      super(attributes)

      @poll = poll
    end

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        poll.update!(name: event, description: description, end_voting_at: end_voting_date)
        sync_options
      end

      poll.reload

      true
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)

      false
    end

    private

    def options_input
      @_options_input ||= Poll::OptionsInput.new(options, zone: poll.zone)
    end

    def sync_options
      entries = options_input.entries.index_by(&:start)

      poll.options.each do |option|
        entry = entries.delete(option.start)

        if entry.nil?
          poll.update!(final_option: nil, closed_at: nil) if poll.final_option_id == option.id
          option.destroy!
        elsif entry.duration_minutes != option.duration_minutes
          option.update!(duration_minutes: entry.duration_minutes)
        end
      end

      entries.each_value { poll.options.create!(it.to_h) }
    end

    def end_voting_date
      poll.zone.parse(end_voting_at.to_s)&.end_of_day
    rescue ArgumentError
      nil
    end

    def end_voting_date_is_valid
      return if end_voting_at.blank?

      deadline = end_voting_date

      if deadline.nil?
        errors.add(:end_voting_at, "is not a valid date")
      elsif deadline.past? && deadline.to_date != poll.end_voting_at.in_time_zone(poll.zone).to_date
        errors.add(:end_voting_at, "must be today or later")
      end
    end

    def options_are_valid
      if !options_input.valid?
        options_input.errors.each { errors.add(:options, it) }
      elsif options_input.entries.size < 2
        errors.add(:options, "must include at least 2 dates or times for voting")
      end
    end
  end
end
