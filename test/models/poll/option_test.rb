require "test_helper"

class Poll::OptionTest < ActiveSupport::TestCase
  context "associations" do
    should belong_to(:poll)
  end
end
