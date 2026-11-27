# frozen_string_literal: true

require "test_helper"

class MyPollsTest < ActiveSupport::TestCase
  setup do
    @cookies = ActionDispatch::TestRequest.create.cookie_jar
  end

  test "is empty for a new browser" do
    assert_empty MyPolls.new(@cookies).call
  end

  test "lists polls this browser organizes or answered" do
    PollSession.new(polls(:one), @cookies).remember_admin
    PollSession.new(polls(:two), @cookies).remember_participant(poll_participants(:bob_two))

    result = MyPolls.new(@cookies).call.index_by { it[:name] }

    assert_equal "organizer", result["Team offsite planning"][:role]
    assert_equal "/#{polls(:one).to_param}/admin/#{polls(:one).admin_token}", result["Team offsite planning"][:admin_path]

    assert_equal "participant", result["Quarterly review"][:role]
    assert_nil result["Quarterly review"][:admin_path]
  end

  test "ignores forged or stale cookies" do
    @cookies[PollSession.new(polls(:one), @cookies).send(:admin_key)] = polls(:one).admin_token
    @cookies.signed["sroodle_participant_#{polls(:two).eid}"] = "no-such-token"

    assert_empty MyPolls.new(@cookies).call
  end

  test "ignores polls that were deleted" do
    PollSession.new(polls(:one), @cookies).remember_admin
    polls(:one).destroy!

    assert_empty MyPolls.new(@cookies).call
  end
end
