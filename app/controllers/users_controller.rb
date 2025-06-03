class UsersController < ApplicationController
  def login
    render inertia: "Auth/Login", props: {}
  end

  def logout
    sign_out

    redirect_to new_poll_path, notice: "You have been logged out successfully."
  end
end
