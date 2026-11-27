# frozen_string_literal: true

class Poll
  # Turns the submitted options into option attributes:
  #
  #   [{date: "2030-06-15", time: "", duration_minutes: 1440},   # all day
  #    {date: "2030-06-15", time: "18:00", duration_minutes: 90}] # timed
  #
  # All-day options start at midnight UTC so they show the same calendar day
  # everywhere. Timed options are read in the organizer's time zone.
  class OptionsInput
    ALL_DAY = 1440
    DURATIONS = (15..720).step(15).to_a.freeze
    TIME = /\A([01]\d|2[0-3]):[0-5]\d\z/

    Entry = Data.define(:start, :duration_minutes) do
      def all_day? = duration_minutes == ALL_DAY
    end

    attr_reader :errors

    def initialize(raw, zone:)
      self.raw = Array(raw)
      self.zone = zone
      @errors = []
    end

    def valid?
      entries
      errors.empty?
    end

    # Unique entries, sorted by start.
    def entries
      @_entries ||= raw.filter_map { parse(it) }.uniq(&:start).sort_by(&:start)
    end

    private

    attr_accessor :raw, :zone

    def parse(item)
      item = item.to_h.with_indifferent_access
      date = Date.iso8601(item[:date].to_s)
      time = item[:time].to_s

      if time.blank?
        Entry.new(start: Time.utc(date.year, date.month, date.day), duration_minutes: ALL_DAY)
      else
        parse_timed(date, time, item[:duration_minutes].to_i)
      end
    rescue Date::Error
      add_error("contains invalid date format")
    end

    def parse_timed(date, time, duration)
      return add_error("contains an invalid time") unless TIME.match?(time)
      return add_error("contains an invalid duration") unless DURATIONS.include?(duration)

      Entry.new(start: zone.parse("#{date.iso8601} #{time}"), duration_minutes: duration)
    end

    def add_error(message)
      errors << message unless errors.include?(message)
      nil
    end
  end
end
