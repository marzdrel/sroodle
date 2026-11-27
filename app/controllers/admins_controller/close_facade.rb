# frozen_string_literal: true

class AdminsController
  class CloseFacade
    include FindPoll

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      FacadeResult.new(
        success?: close,
        errors: errors,
        data: {admin_path: admin_path}
      )
    end

    private

    attr_accessor :params, :errors

    def close
      option = poll.options.find { it.to_param == params[:option_id] }

      if option.nil?
        self.errors = {option_id: "Pick one of the poll's dates."}
        return false
      end

      self.errors = {}
      poll.close!(option)
    end
  end
end
