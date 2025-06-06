# frozen_string_literal: true

class PollsController
  class ShowFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, current_user)
      self.params = params
      self.current_user = current_user
    end

    def call
      FacadeResult.new(
        success?: true,
        current_user: current_user,
        data: {
          poll: serialize(poll),
          participants: mock_participants # This will be real data in the future
        },
        errors: {}
      )
    end

    private

    attr_accessor :params, :current_user

    def poll
      @_poll ||= Poll.includes(:creator).exid_loader(params.fetch(:id))
    end

    def serialize(poll)
      {
        id: poll.to_param,
        name: poll.name,
        event: poll.name, # Using name as event name for now
        description: poll.description,
        creator: {
          email: poll.creator.email,
          name: poll.creator.email.split("@").first # Mock name for now
        },
        created_at: poll.created_at,
        dates: mock_dates, # This will be real data in the future
        vote_path: routes.new_poll_vote_path(poll)
      }
    end

    def routes
      Rails.application.routes.url_helpers
    end

    # Mock data for UI development - will be replaced with real data later
    def mock_dates
      # Generate 5 dates starting from tomorrow
      dates = []
      5.times do |i|
        date = (Date.today + i + 1).iso8601
        dates << {
          date: date,
          responses: {
            yes: rand(0..5),
            maybe: rand(0..3),
            no: rand(0..2)
          }
        }
      end
      dates
    end

    # Mock participants for UI development - will be replaced with real data later
    def mock_participants
      return [] if params[:empty_participants] # Allow testing empty state

      first_names = ["Alice", "Bob", "Charlie", "David", "Emma"]
      last_names = ["Smith", "Johnson", "Williams", "Brown", "Jones"]

      dates = mock_dates.map { |d| d[:date] }

      participants = []
      3.times do |i|
        name = "#{first_names[i]} #{last_names[i]}"
        email = "#{name.downcase.tr(" ", ".")}@example.com"

        responses = dates.map do |date|
          preferences = ["yes", "maybe", "no"]
          {
            date: date,
            preference: preferences.sample
          }
        end

        participants << {
          id: i + 1,
          name: name,
          email: email,
          responses: responses
        }
      end

      participants
    end
  end
end
