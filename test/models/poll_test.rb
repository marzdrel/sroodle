require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "requires a title" do
    assert_must validate_presence_of(:name), polls(:one)
  end
end
