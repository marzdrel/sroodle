class ApplicationController < ActionController::Base
  include Clearance::Controller
  # allow_browser versions: :modern
end
