require "test_helper"

class Poll::OptionTest < ActiveSupport::TestCase
  test "belongs to poll" do
    assert_must belong_to(:poll), Poll::Option.new
  end
end
