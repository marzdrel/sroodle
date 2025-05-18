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
      errors = Poll.create(name: params[:name]).errors.to_hash
      errors = errors.transform_values(&:to_sentence)

      Result.new(false, {}, errors)
    end

    private

    attr_accessor :params
  end
end
