# frozen_string_literal: true

class PollsController
  class NewFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, current_user)
      self.params = params
      self.current_user = current_user
    end

    def call
      # In a real app, you might fetch default values from a database,
      # user preferences, or other sources.
      default_data = {
        name: params[:name] || current_user_name,
        email: params[:email] || current_user_email,
        event: params[:event] || "My Event",
        description: params[:description] || ""
      }

      FacadeResult.new(
        success?: true,
        data: {
          poll: default_data
        },
        errors: []
      )
    end

    private

    attr_accessor :params, :current_user

    def current_user_name
      # In a real app with authentication, you might return the user's name
      # For now, using a placeholder
      "Event Organizer"
    end

    def current_user_email
      # In a real app with authentication, you might return the user's email
      # For now, using a placeholder
      current_user&.email || "organizer@example.com"
    end
  end
end
