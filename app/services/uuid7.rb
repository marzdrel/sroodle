# frozen_string_literal: true

# UUIDv7 with millisecond precision layout

# rubocop:disable Style/FormatStringToken
class UUID7
  VERSION_7 = 0x7000
  VARIANT_RFC4122 = 0x8000

  def self.generate(...)
    new(...).to_str
  end

  def initialize(timestamp: nil)
    self.timestamp = timestamp || timestamp_now

    uuid
  end

  def to_str
    format("%08x-%04x-%04x-%04x-%04x%08x", *uuid)
  end

  def hex
    format("%08x%04x%04x%04x%04x%08x", *uuid)
  end

  alias to_s to_str

  private

  attr_reader :timestamp

  def timestamp=(value)
    case value
    in Integer
      @timestamp = value
    in Time
      @timestamp = (value.to_f * 1000).to_i
    end
  end

  def timestamp_now
    Process.clock_gettime(Process::CLOCK_REALTIME, :millisecond)
  end

  def uuid
    @_uuid ||= build
  end

  def build
    # take 48 least significant bits of timestamp
    unix_ts_ms = timestamp & 0xffffffffffff

    # take 32 most significant bits of timestamp
    unix_ts_ms1 = (unix_ts_ms >> 16) & 0xffffffff

    # take 16 least significant bits of timestamp
    unix_ts_ms2 = (unix_ts_ms & 0xffff)

    rand_a, rand_b1, rand_b2, rand_b3 =
      SecureRandom.gen_random(10).unpack("nnnN")

    # take 12 bits of 16
    rand_a &= 0xfff

    # take 14 bits of 16
    rand_b1 &= 0x3fff

    # https://www.ietf.org/id/draft-peabody-dispatch-new-uuid-format-03.txt#section-5.2
    #  0                   1                   2                   3
    #  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |                           unix_ts_ms                          |
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |          unix_ts_ms           |  ver  |       rand_a          |
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |var|                        rand_b                             |
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    # |                            rand_b                             |
    # +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+

    # layout in bits [32, 16, 16, 16, 16, 32]
    [
      unix_ts_ms1,
      unix_ts_ms2,
      (VERSION_7 | rand_a),
      (VARIANT_RFC4122 | rand_b1),
      rand_b2,
      rand_b3,
    ]
  end
end
# rubocop:enable Style/FormatStringToken
