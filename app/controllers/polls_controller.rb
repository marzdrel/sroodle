class PollsController < ApplicationController
  def new
    render(
      inertia: "Poll/New",
      props: {
        poll: "POLL"
      }
    )
  end
end
