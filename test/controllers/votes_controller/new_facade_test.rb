# frozen_string_literal: true

require "test_helper"

class VotesController
  class NewFacadeTest < ActiveSupport::TestCase
    setup do
      @poll = polls(:one)
      @user = users(:alice)
      @valid_params = ActionController::Parameters.new(
        id: @poll.exid_value
      )
    end

    test "returns successful result with valid poll id" do
      result = VotesController::NewFacade.call(@valid_params, @user)

      assert result.success?
      assert_empty result.errors
    end

    test "returns unsuccessful result with invalid poll id" do
      invalid_params = ActionController::Parameters.new(
        id: "invalid_poll_id"
      )

      assert_raises(Exid::Error) do
        VotesController::NewFacade.call(invalid_params, @user)
      end
    end

    test "returns unsuccessful result with missing poll id" do
      invalid_params = ActionController::Parameters.new({})

      assert_raises(KeyError) do
        VotesController::NewFacade.call(invalid_params, @user)
      end
    end

    test "result data contains expected poll structure" do
      result = VotesController::NewFacade.call(@valid_params, @user)

      assert_kind_of Hash, result.data
      assert result.data.key?(:poll)

      poll_data = result.data[:poll]
      assert_kind_of Hash, poll_data
      assert_equal @poll.exid_value, poll_data[:id]
      assert_equal @poll.name, poll_data[:name]
      assert_equal @poll.description, poll_data[:description]
      assert poll_data.key?(:options)
      assert_kind_of Array, poll_data[:options]
    end

    test "includes poll options in result data" do
      result = VotesController::NewFacade.call(@valid_params, @user)

      poll_data = result.data[:poll]
      options = poll_data[:options]

      assert_equal @poll.options.count, options.count

      options.each do |option|
        assert option.key?(:id)
        assert option.key?(:start)
        assert option.key?(:duration_minutes)
      end
    end

    test "works with nil current_user" do
      result = VotesController::NewFacade.call(@valid_params, nil)

      assert result.success?
      assert_empty result.errors
      assert result.data.key?(:poll)
    end

    test "result includes current_user" do
      result = VotesController::NewFacade.call(@valid_params, @user)

      assert result.respond_to?(:current_user)
      assert_equal @user, result.current_user
    end

    test "poll options have correct structure" do
      result = VotesController::NewFacade.call(@valid_params, @user)

      poll_data = result.data[:poll]
      options = poll_data[:options]

      @poll.options.each_with_index do |option, index|
        result_option = options[index]
        assert_equal option.exid_value, result_option[:id]
        assert_equal option.start, result_option[:start]
        assert_equal option.duration_minutes, result_option[:duration_minutes]
      end
    end
  end
end
