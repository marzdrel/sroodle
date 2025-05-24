require "test_helper"

class Poll::OptionTest < ActiveSupport::TestCase
  set_fixture_class poll_options: Poll::Option

  test "fixtures are valid" do
    assert poll_options(:morning_meeting).valid?, "poll_options(:morning_meeting) should be valid"
    assert poll_options(:afternoon_meeting).valid?, "poll_options(:afternoon_meeting) should be valid"
    assert poll_options(:evening_meeting).valid?, "poll_options(:evening_meeting) should be valid"
    assert poll_options(:quick_standup).valid?, "poll_options(:quick_standup) should be valid"
    assert poll_options(:half_day_workshop).valid?, "poll_options(:half_day_workshop) should be valid"
  end

  test "belongs to poll" do
    assert_must belong_to(:poll), Poll::Option.new
  end

  test "poll association works" do
    option = poll_options(:morning_meeting)
    assert_equal polls(:one), option.poll
  end

  test "has valid duration minutes from fixtures" do
    assert_equal 60, poll_options(:morning_meeting).duration_minutes
    assert_equal 90, poll_options(:afternoon_meeting).duration_minutes
    assert_equal 30, poll_options(:evening_meeting).duration_minutes
    assert_equal 30, poll_options(:quick_standup).duration_minutes
    assert_equal 1440, poll_options(:half_day_workshop).duration_minutes
  end

  test "has start times in fixtures" do
    assert_not_nil poll_options(:morning_meeting).start
    assert_not_nil poll_options(:afternoon_meeting).start
    assert_not_nil poll_options(:evening_meeting).start
    assert_not_nil poll_options(:quick_standup).start
    assert_not_nil poll_options(:half_day_workshop).start
  end

  test "duration minutes constraint allows valid values" do
    option = poll_options(:morning_meeting)

    [30, 60, 90, 120, 1440].each do |valid_duration|
      option.duration_minutes = valid_duration
      assert option.valid?, "Duration #{valid_duration} should be valid"
    end
  end
end
