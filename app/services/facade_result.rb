# frozen_string_literal: true

FacadeResult =
  Data.define(:success?, :data, :errors) do
    def initialize(data: {}, errors: {}, **rest)
      super
    end

    def props
      output = data.merge(errors: errors)

      if Rails.env.development?
        output.merge(debug: output.inspect)
      else
        output
      end
    end
  end
