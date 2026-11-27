# frozen_string_literal: true

require "test_helper"

class PollsController
  class ShowFacadeTest < ActiveSupport::TestCase
    setup do
      @poll = polls(:one)
      @params = ActionController::Parameters.new(id: @poll.to_param)
      @cookies = ActionDispatch::TestRequest.create.cookie_jar
    end

    test "returns the poll without any email addresses" do
      result = ShowFacade.call(@params, @cookies)

      assert result.success?
      assert_equal "Team offsite planning", result.data[:poll][:name]
      assert_equal "Alice", result.data[:poll][:organizer_name]
      assert_no_match(/@/, result.props.to_json)
    end

    test "lists the real options in date order with counts" do
      result = ShowFacade.call(@params, @cookies)
      options = result.data[:options]

      assert_equal(
        [:morning_meeting, :afternoon_meeting, :evening_meeting].map { poll_options(it).to_param },
        options.map { it[:id] }
      )

      assert_equal({"yes" => 1, "maybe" => 1, "no" => 0}, options[0][:counts])
      assert_equal({"yes" => 1, "maybe" => 1, "no" => 0}, options[1][:counts])
      assert_equal({"yes" => 0, "maybe" => 0, "no" => 1}, options[2][:counts])
    end

    test "lists every participant with their answers" do
      result = ShowFacade.call(@params, @cookies)
      alice, bob = result.data[:participants]

      assert_equal "Alice", alice[:name]
      assert_equal "yes", alice[:responses][poll_options(:morning_meeting).to_param]
      assert_equal "no", alice[:responses][poll_options(:evening_meeting).to_param]

      assert_equal "Bob", bob[:name]
      assert_nil bob[:responses][poll_options(:evening_meeting).to_param]
    end

    test "picks the options with the most yes answers, maybe breaking ties" do
      result = ShowFacade.call(@params, @cookies)

      assert_equal(
        [poll_options(:morning_meeting).to_param, poll_options(:afternoon_meeting).to_param],
        result.data[:best_option_ids]
      )

      poll_votes(:bob_morning_maybe).update!(response: "no")
      result = ShowFacade.call(@params, @cookies)

      assert_equal [poll_options(:afternoon_meeting).to_param], result.data[:best_option_ids]
    end

    test "has no best option before anyone answers yes or maybe" do
      @poll.votes.update_all(response: "no")

      result = ShowFacade.call(@params, @cookies)

      assert_empty result.data[:best_option_ids]
    end

    test "marks the participant using this browser" do
      PollSession.new(@poll, @cookies).remember_participant(poll_participants(:bob_one))

      result = ShowFacade.call(@params, @cookies)

      assert result.data[:you_voted]
      assert_equal [false, true], result.data[:participants].map { it[:you] }
    end

    test "raises RecordNotFound for an unknown poll" do
      params = ActionController::Parameters.new(id: Poll.new(eid: UUID7.generate).to_param)

      assert_raises(ActiveRecord::RecordNotFound) do
        ShowFacade.call(params, @cookies)
      end
    end
  end
end
