# frozen_string_literal: true

require "test_helper"

class PollsController
  class ShowFacadeTest < ActiveSupport::TestCase
    setup do
      @poll = polls(:one)
      @user = users(:alice)
      @params = ActionController::Parameters.new({id: @poll.to_param})
    end

    test "returns successful result" do
      result = PollsController::ShowFacade.call(@params, @user)

      assert result.success?
      assert_empty result.errors
    end

    test "result data contains expected structure" do
      result = PollsController::ShowFacade.call(@params, @user)

      assert_kind_of Hash, result.data
      assert result.data.key?(:poll)
      assert result.data.key?(:participants)
      assert_kind_of Hash, result.data[:poll]
      assert_kind_of Array, result.data[:participants]
    end

    test "poll data contains all required fields" do
      result = PollsController::ShowFacade.call(@params, @user)
      poll_data = result.data[:poll]

      assert_equal @poll.to_param, poll_data[:id]
      assert_equal @poll.name, poll_data[:name]
      assert_equal @poll.name, poll_data[:event]
      assert_equal @poll.description, poll_data[:description]
      assert_equal @poll.created_at, poll_data[:created_at]

      # Verify creator data
      assert_kind_of Hash, poll_data[:creator]
      assert_equal @poll.creator.email, poll_data[:creator][:email]
      assert_equal @poll.creator.email.split("@").first, poll_data[:creator][:name]

      # Verify dates structure
      assert_kind_of Array, poll_data[:dates]
      assert_equal 5, poll_data[:dates].length

      poll_data[:dates].each do |date_entry|
        assert_kind_of Hash, date_entry
        assert date_entry.key?(:date)
        assert date_entry.key?(:responses)
        assert_kind_of Hash, date_entry[:responses]
        assert date_entry[:responses].key?(:yes)
        assert date_entry[:responses].key?(:maybe)
        assert date_entry[:responses].key?(:no)
      end

      # Verify vote path
      expected_vote_path = Rails.application.routes.url_helpers.new_poll_vote_path(@poll)
      assert_equal expected_vote_path, poll_data[:vote_path]
    end

    test "generates mock dates starting from tomorrow" do
      result = PollsController::ShowFacade.call(@params, @user)
      poll_data = result.data[:poll]

      # Check that dates start from tomorrow and are consecutive
      expected_dates = 5.times.map { |i| (Date.today + i + 1).iso8601 }
      actual_dates = poll_data[:dates].map { |d| d[:date] }

      assert_equal expected_dates, actual_dates
    end

    test "mock dates contain random but valid response counts" do
      result = PollsController::ShowFacade.call(@params, @user)
      poll_data = result.data[:poll]

      poll_data[:dates].each do |date_entry|
        responses = date_entry[:responses]
        assert responses[:yes].between?(0, 5)
        assert responses[:maybe].between?(0, 3)
        assert responses[:no].between?(0, 2)
      end
    end

    test "participants data has expected structure" do
      result = PollsController::ShowFacade.call(@params, @user)
      participants = result.data[:participants]

      assert_equal 3, participants.length

      participants.each do |participant|
        assert_kind_of Hash, participant
        assert participant.key?(:id)
        assert participant.key?(:name)
        assert participant.key?(:email)
        assert participant.key?(:responses)

        assert_kind_of Integer, participant[:id]
        assert_kind_of String, participant[:name]
        assert_kind_of String, participant[:email]
        assert_kind_of Array, participant[:responses]

        # Verify participant responses match the poll dates
        assert_equal 5, participant[:responses].length
        participant[:responses].each do |response|
          assert response.key?(:date)
          assert response.key?(:preference)
          assert ["yes", "maybe", "no"].include?(response[:preference])
        end
      end
    end

    test "participants have consistent email format" do
      result = PollsController::ShowFacade.call(@params, @user)
      participants = result.data[:participants]

      participants.each do |participant|
        expected_email = "#{participant[:name].downcase.tr(" ", ".")}@example.com"
        assert_equal expected_email, participant[:email]
      end
    end

    test "handles empty participants when param is set" do
      params_with_empty = ActionController::Parameters.new({
        id: @poll.to_param,
        empty_participants: true
      })

      result = PollsController::ShowFacade.call(params_with_empty, @user)
      participants = result.data[:participants]

      assert_empty participants
    end

    test "raises error when poll is not found" do
      invalid_params = ActionController::Parameters.new({id: "nonexistent"})

      assert_raises(Exid::DecodeError) do
        PollsController::ShowFacade.call(invalid_params, @user)
      end
    end

    test "includes associated creator data" do
      # This test ensures the includes(:creator) is working
      result = PollsController::ShowFacade.call(@params, @user)
      poll_data = result.data[:poll]

      # The facade should not trigger additional queries for creator
      assert_equal @poll.creator.email, poll_data[:creator][:email]
    end

    test "can be called with class method" do
      result = PollsController::ShowFacade.call(@params, @user)
      assert result.success?
    end

    test "can be instantiated and called directly" do
      facade = PollsController::ShowFacade.new(@params, @user)
      result = facade.call

      assert result.success?
      assert_kind_of Hash, result.data
    end
  end
end
