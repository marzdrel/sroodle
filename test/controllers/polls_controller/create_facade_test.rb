# frozen_string_literal: true

require "test_helper"

class PollsController
  class CreateFacadeTest < ActiveSupport::TestCase
    setup do
      @user = users(:alice)
      @valid_params = ActionController::Parameters.new(
        poll: {
          name: "John Doe",
          email: "john@example.com",
          event: "Team Meeting",
          description: "Weekly team meeting to discuss project progress",
          end_voting_at: "2023-10-15",
          dates: ["2023-10-01", "2023-10-02"]
        }
      )
    end

    test "returns successful result with valid parameters" do
      result = PollsController::CreateFacade.call(@valid_params, @user)

      assert result.success?
      assert_empty result.errors
    end

    test "returns unsuccessful result with invalid parameters" do
      invalid_params = ActionController::Parameters.new(
        poll: {
          name: "",
          email: "invalid-email",
          event: "",
          description: "too short"
        }
      )

      result = PollsController::CreateFacade.call(invalid_params, @user)

      assert_not result.success?
      assert_not_empty result.errors
    end

    test "returns appropriate error messages" do
      invalid_params = ActionController::Parameters.new(
        poll: {
          name: "",
          email: "invalid-email",
          event: ""
        }
      )

      result = PollsController::CreateFacade.call(invalid_params, @user)

      assert result.errors.key?(:name)
      assert result.errors.key?(:email)
      assert result.errors.key?(:event)
    end

    test "result data contains expected structure" do
      result = PollsController::CreateFacade.call(@valid_params, @user)

      assert_kind_of Hash, result.data
    end
  end
end
