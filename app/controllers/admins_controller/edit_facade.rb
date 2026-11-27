# frozen_string_literal: true

class AdminsController
  class EditFacade
    include FindPoll
    include EditProps

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      FacadeResult.new(success?: true, data: edit_props)
    end

    private

    attr_accessor :params

    def poll_scope = Poll.includes(:options)
  end
end
