require "test_helper"

class PollTest < ActiveSupport::TestCase
  test "requires a title" do
    assert_accepts Poll, have_many(:comments).dependent(:destroy)
  end
end
