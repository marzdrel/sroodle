# frozen_string_literal: true

# An iCalendar (.ics) file with one event for the poll's final date, so
# participants can add it to their calendar.
class PollCalendar
  ESCAPES = {"\\" => "\\\\", ";" => "\\;", "," => "\\,"}.freeze

  def initialize(poll, url:)
    self.poll = poll
    self.url = url
  end

  def to_ics
    lines = [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:-//Sroodle//Sroodle//EN",
      "CALSCALE:GREGORIAN",
      "BEGIN:VEVENT",
      "UID:#{option.eid}@sroodle",
      "DTSTAMP:#{utc(Time.current)}",
      *timing,
      "SUMMARY:#{escape(poll.name)}",
      ("DESCRIPTION:#{escape(poll.description)}" if poll.description.present?),
      "URL:#{url}",
      "END:VEVENT",
      "END:VCALENDAR"
    ]

    lines.compact.map { fold(it) }.join("\r\n") + "\r\n"
  end

  private

  attr_accessor :poll, :url

  def option = poll.final_option

  def timing
    if option.duration_minutes >= 1440
      date = option.start.utc.to_date

      [
        "DTSTART;VALUE=DATE:#{date.strftime("%Y%m%d")}",
        "DTEND;VALUE=DATE:#{(date + (option.duration_minutes / 1440)).strftime("%Y%m%d")}"
      ]
    else
      [
        "DTSTART:#{utc(option.start)}",
        "DTEND:#{utc(option.start + option.duration_minutes.minutes)}"
      ]
    end
  end

  def utc(time) = time.utc.strftime("%Y%m%dT%H%M%SZ")

  def escape(text)
    text.to_s.gsub(/\r?\n|[\\;,]/) { ESCAPES.fetch(it, "\\n") }
  end

  # Lines longer than 75 octets are folded (RFC 5545, section 3.1).
  def fold(line)
    return line if line.bytesize <= 75

    chunks = []
    current = +""
    line.each_char do |char|
      if (current + char).bytesize > (chunks.empty? ? 75 : 74)
        chunks << current
        current = +""
      end
      current << char
    end
    chunks << current

    chunks.join("\r\n ")
  end
end
