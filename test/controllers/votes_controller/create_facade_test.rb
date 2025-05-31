# frozen_string_literal: true

require "test_helper"

class VotesController
  class CreateFacadeTest < ActiveSupport::TestCase
    setup do
      @poll = polls(:one)
      # Create a new user who hasn't voted yet to avoid unique constraint violations
      @user = User.create!(
        email: "newuser@example.com",
        password: "password",
        status: "active"
      )
      @morning_option = poll_options(:morning_meeting)
      @afternoon_option = poll_options(:afternoon_meeting)
      @evening_option = poll_options(:evening_meeting)

      @valid_params = ActionController::Parameters.new(
        poll_id: @poll.exid_value,
        vote: {
          name: "John",
          email: "jd@example.com",
          responses: {
            @morning_option.exid_value => "yes",
            @afternoon_option.exid_value => "maybe",
            @evening_option.exid_value => "no"
          }
        }
      )
    end

    test "returns successful result with valid parameters" do
      result = VotesController::CreateFacade.call(@valid_params, @user)

      assert result.success?
      assert_empty result.errors
      assert result.data[:poll].present?
    end

    test "returns unsuccessful result with invalid poll_id" do
      invalid_params = ActionController::Parameters.new(
        poll_id: "invalid_poll_id",
        vote: {
          name: "John",
          email: "jd@example.com",
          responses: {
            @morning_option.exid_value => "yes"
          }
        }
      )

      assert_raises(Exid::Error) do
        VotesController::CreateFacade.call(invalid_params, @user)
      end
    end

    test "returns unsuccessful result with invalid option responses" do
      invalid_params = ActionController::Parameters.new(
        poll_id: @poll.exid_value,
        vote: {
          name: "John",
          email: "jd@example.com",
          responses: {
            "invalid_option_id" => "yes"
          }
        }
      )

      result = VotesController::CreateFacade.call(invalid_params, @user)

      assert_not result.success?
      assert result.errors.present?
    end

    test "returns unsuccessful result with missing responses" do
      invalid_params = ActionController::Parameters.new(
        poll_id: @poll.exid_value,
        vote: {
          name: "John",
          email: "jd@example.com",
          responses: {}
        }
      )

      result = VotesController::CreateFacade.call(invalid_params, @user)

      assert_not result.success?
      assert result.errors.present?
    end

    test "creates votes with correct associations" do
      result = VotesController::CreateFacade.call(@valid_params, @user)

      assert result.success?
      assert result.data[:votes].present?
      assert_equal 3, result.data[:votes].count

      result.data[:votes].each do |vote|
        assert_equal @poll.id, vote.poll_id
        assert_not_nil vote.user
      end
    end

    test "result data contains votes and poll" do
      result = VotesController::CreateFacade.call(@valid_params, @user)

      assert result.data.key?(:votes)
      assert result.data.key?(:poll)
      assert_kind_of Array, result.data[:votes]
      assert_kind_of Hash, result.data[:poll]
    end

    test "increments vote count" do
      initial_count = Poll::Vote.count

      result = VotesController::CreateFacade.call(@valid_params, @user)

      assert result.success?
      assert_equal initial_count + 3, Poll::Vote.count
    end

    test "returns unsuccessful result with invalid response values" do
      invalid_params = ActionController::Parameters.new(
        poll_id: @poll.exid_value,
        vote: {
          name: "John",
          email: "jd@example.com",
          responses: {
            @morning_option.exid_value => "invalid_response"
          }
        }
      )

      result = VotesController::CreateFacade.call(invalid_params, @user)

      assert_not result.success?
      assert result.errors.present?
    end
  end
end
