# frozen_string_literal: true

require "test_helper"

class User::PropsSerializerTest < ActiveSupport::TestCase
  test "serializes user props with email and exid_value" do
    user = users(:alice)
    serializer = User::PropsSerializer.new(user)

    result = serializer.call

    assert_equal user.email, result[:email]
    assert_equal user.exid_value, result[:exid_value]
  end

  test "returns hash with expected keys" do
    user = users(:bob)
    serializer = User::PropsSerializer.new(user)

    result = serializer.call

    assert_includes result.keys, :email
    assert_includes result.keys, :exid_value
    assert_equal 2, result.keys.length
  end
end
