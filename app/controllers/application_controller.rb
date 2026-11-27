class ApplicationController < ActionController::Base
  inertia_share do
    {
      new_poll_path: new_poll_path,
      flash: flash.to_hash.slice("notice", "alert")
    }
  end

  rescue_from NoMatchingPatternError, Exid::Error, with: :render_not_found

  private

  def render_not_found
    raise ActiveRecord::RecordNotFound
  end
end
