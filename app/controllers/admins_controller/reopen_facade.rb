# frozen_string_literal: true

class AdminsController
  class ReopenFacade
    include FindPoll

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      poll.reopen!

      FacadeResult.new(success?: true, data: {admin_path: admin_path})
    end

    private

    attr_accessor :params
  end
end
