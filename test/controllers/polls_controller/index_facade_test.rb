# frozen_string_literal: true

require "test_helper"

class PollsController
  class IndexFacadeTest < ActiveSupport::TestCase
    setup do
      @user = users(:alice)
      @params = ActionController::Parameters.new({})
    end

    test "returns successful result" do
      result = PollsController::IndexFacade.call(@params, @user)

      assert result.success?
      assert_empty result.errors
    end

    test "result data contains expected structure" do
      result = PollsController::IndexFacade.call(@params, @user)

      assert_kind_of Hash, result.data
      assert result.data.key?(:polls)
      assert_kind_of Array, result.data[:polls]
    end

    test "works with nil current_user" do
      result = PollsController::IndexFacade.call(@params, nil)

      assert result.success?
      assert_empty result.errors
    end
  end
end
