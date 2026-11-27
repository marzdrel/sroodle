# frozen_string_literal: true

class PollsController
  class NewFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      FacadeResult.new(
        success?: true,
        data: {
          poll: {
            name: params[:name].to_s,
            email: params[:email].to_s,
            event: params[:event].to_s,
            description: params[:description].to_s
          }
        }
      )
    end

    private

    attr_accessor :params
  end
end
