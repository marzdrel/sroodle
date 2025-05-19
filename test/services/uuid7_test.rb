# frozen_string_literal: true

require "test_helper"

class UUID7::Test < ActiveSupport::TestCase
  test "generate a UUID v7 string" do
    assert_match(/\A\w{8}-\w{4}-7\w{3}-\w{4}-\w{4}\w{8}\Z/, UUID7.generate)
  end

  test "generates different UUIDs" do
    uuid7a = UUID7.generate
    uuid7b = UUID7.generate

    assert_not_equal uuid7a, uuid7b
  end

  test "generates prefixed UUID with Integer timestamp" do
    uuid7 = UUID7.new(timestamp: 1712950109185).to_str

    assert_match(/\A018ed3c8-64/, uuid7)
  end

  test "generates prefixed UUID with Time timestamp" do
    timestamp = Time.zone.parse("2024-04-12 21:29:55.752266")
    uuid7 = UUID7.new(timestamp: timestamp).to_str

    assert_match(/\A018ed437-93/, uuid7)
  end

  test "hex returns UUID without dashes" do
    assert_match(/\A\w{32}\Z/, UUID7.new.hex)
  end
end
