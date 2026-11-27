# frozen_string_literal: true

class AdminsController
  # Loads the poll for an admin URL. A wrong token raises RecordNotFound
  # (404), the same as an unknown poll, so the response doesn't reveal which
  # part was wrong.
  module FindPoll
    private

    def poll
      @_poll ||= begin
        poll = poll_scope.exid_loader(params.fetch(:id))
        raise ActiveRecord::RecordNotFound unless poll.admin_token?(params[:token])

        poll
      end
    end

    def poll_scope = Poll

    def admin_path
      Rails.application.routes.url_helpers.poll_admin_path(poll, token: poll.admin_token)
    end
  end
end
