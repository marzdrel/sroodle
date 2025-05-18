# frozen_string_literal: true

class PollsController
  class CreateFacade
    Result = Data.define(:success?, :data, :errors)

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      Result.new(false, {}, [])
    end

    private

    attr_accessor :params
  end
end
