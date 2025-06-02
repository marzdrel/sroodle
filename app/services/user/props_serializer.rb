# frozen_string_literal: true

class User
  class PropsSerializer
    def self.call(...)
      new(...).call
    end

    def initialize(user)
      self.user = user
    end

    def call
      {
        email: user.email,
        exid_value: user.exid_value
      }
    end

    private

    attr_accessor :user
  end
end
