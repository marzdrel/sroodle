require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "fixtures are valid" do
    assert polls(:one).valid?, "polls(:one) should be valid"
    assert polls(:two).valid?, "polls(:two) should be valid"
  end

  test "belongs to creator" do
    assert_must belong_to(:creator), Poll.new
  end

  test "requires a name" do
    assert_must validate_presence_of(:name), Poll.new
  end

  test "validates name length" do
    assert_must validate_length_of(:name).is_at_least(5).is_at_most(100), Poll.new
  end

  test "has exid functionality" do
    poll = polls(:one)
    assert_not_nil poll.eid
    assert_equal poll.exid_value, poll.to_param
  end

  test "creator association works" do
    poll = polls(:one)
    assert_equal users(:alice), poll.creator
  end
end
