# frozen_string_literal: true

class AdminsController
  class DestroyFacade
    include FindPoll

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      poll.destroy!

      FacadeResult.new(success?: true)
    end

    private

    attr_accessor :params
  end
end
