# frozen_string_literal: true

class PollsController
  class NewFacade
    def self.call(...)
      new(...).call
    end

    def initialize(params, cookies)
      self.params = params
      self.cookies = cookies
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
          },
          my_polls: MyPolls.new(cookies).call
        }
      )
    end

    private

    attr_accessor :params, :cookies
  end
end
