ENV["RAILS_ENV"] ||= "test"

require_relative "../config/environment"

# Prevent database truncation if the environment is other than test
unless Rails.env.test?
  abort("The Rails environment is running in non-test mode!")
end

require "rails/test_help"
require "shoulda/matchers"
require "shoulda/context"
require "minitest/mock"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    def assert_must(matcher, subject, msg = nil)
      assert matcher.matches?(subject), msg
    end
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :minitest
    with.library :rails
  end
end

module InertiaPageHelpers
  # The Inertia page object of the last response, from either a JSON (Inertia
  # visit) or an HTML (first load) response.
  def inertia_page
    return JSON.parse(response.body) if response.media_type == "application/json"

    document = Nokogiri::HTML(response.body)
    script = document.at_css("script[data-page]")

    JSON.parse(script ? script.text : document.at_css("[data-page]")["data-page"])
  end

  def inertia_component = inertia_page["component"]

  def inertia_props = inertia_page["props"]
end

ActionDispatch::IntegrationTest.include(InertiaPageHelpers)
