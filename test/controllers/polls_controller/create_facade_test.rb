# frozen_string_literal: true

require "test_helper"

class PollsController
  class CreateFacadeTest < ActiveSupport::TestCase
    setup do
      @cookies = ActionDispatch::TestRequest.create.cookie_jar
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
      result = PollsController::CreateFacade.call(@valid_params, @cookies)

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

      result = PollsController::CreateFacade.call(invalid_params, @cookies)

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

      result = PollsController::CreateFacade.call(invalid_params, @cookies)

      assert result.errors.key?(:name)
      assert result.errors.key?(:email)
      assert result.errors.key?(:event)
    end

    test "returns the admin path and remembers the organizer" do
      result = PollsController::CreateFacade.call(@valid_params, @cookies)
      poll = Poll.order(:id).last

      assert_equal "/#{poll.to_param}/admin/#{poll.admin_token}", result.data[:admin_path]
      assert PollSession.new(poll, @cookies).admin?
    end

    test "returns the submitted values when invalid" do
      params = ActionController::Parameters.new(poll: {name: "Jo", event: ""})

      result = PollsController::CreateFacade.call(params, @cookies)

      assert_equal "Jo", result.data[:poll]["name"]
    end
  end
end
