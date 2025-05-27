# frozen_string_literal: true

require "test_helper"

class VotesController
  class CreateFacadeTest < ActiveSupport::TestCase
    setup do
      @poll = polls(:one)
      @user = users(:alice)

      @valid_params = ActionController::Parameters.new(
        poll_id: @poll.exid_value,
        vote: {
          name: "John",
          email: "jd@example.com",
          responses: {}
        }
      )
    end

    test "returns successful result with valid parameters" do
      result = VotesController::CreateFacade.call(@valid_params)

      assert result.success?
      assert_empty result.errors
      assert result.data[:vote].persisted?
    end
    #
    # test "returns unsuccessful result with invalid poll_id" do
    #   invalid_params = ActionController::Parameters.new(
    #     poll_id: 99999,
    #     poll_option_id: @poll_option.id
    #   )
    #
    #   result = VotesController::CreateFacade.call(invalid_params)
    #
    #   assert_not result.success?
    #   assert_nil result.data[:vote]
    # end
    #
    # test "returns unsuccessful result with invalid poll_option_id" do
    #   invalid_params = ActionController::Parameters.new(
    #     poll_id: @poll.id,
    #     poll_option_id: 99999
    #   )
    #
    #   result = VotesController::CreateFacade.call(invalid_params)
    #
    #   assert_not result.success?
    #   assert_nil result.data[:vote]
    # end
    #
    # test "returns unsuccessful result with missing poll_option_id" do
    #   invalid_params = ActionController::Parameters.new(
    #     poll_id: @poll.id,
    #     poll_option_id: nil
    #   )
    #
    #   result = VotesController::CreateFacade.call(invalid_params)
    #
    #   assert_not result.success?
    #   assert_nil result.data[:vote]
    # end
    #
    # test "creates vote with correct associations" do
    #   result = VotesController::CreateFacade.call(@valid_params)
    #
    #   vote = result.data[:vote]
    #   assert_equal @poll, vote.poll
    #   assert_equal @poll_option, vote.poll_option
    #   assert_not_nil vote.user
    # end
    #
    # test "result data contains vote" do
    #   result = VotesController::CreateFacade.call(@valid_params)
    #
    #   assert result.data.key?(:vote)
    #   assert_kind_of Poll::Vote, result.data[:vote]
    # end
    #
    # test "increments vote count" do
    #   assert_difference("Poll::Vote.count", 1) do
    #     VotesController::CreateFacade.call(@valid_params)
    #   end
    # end
    #
    # test "handles poll option not belonging to poll" do
    #   other_poll = Poll.create!(
    #     name: "Other Poll",
    #     email: "other@example.com",
    #     name: "Other Event",
    #     description: "Other description",
    #     dates: ["2023-10-01"]
    #   )
    #   other_option = other_poll.options.create!(name: "Other Option")
    #
    #   invalid_params = ActionController::Parameters.new(
    #     poll_id: @poll.id,
    #     poll_option_id: other_option.id
    #   )
    #
    #   result = VotesController::CreateFacade.call(invalid_params)
    #
    #   assert_not result.success?
    #   assert_nil result.data[:vote]
    # end
  end
end
