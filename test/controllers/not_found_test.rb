require "test_helper"

# Unknown or malformed poll ids must be a 404 on every route, never a 500.
class NotFoundTest < ActionDispatch::IntegrationTest
  IDS = %w[poll_doesnotexist poll_0 poll_!!! poll_ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ].freeze

  IDS.each do |id|
    test "GET routes for #{id} are not found" do
      escaped = ERB::Util.url_encode(id)

      [
        "/#{escaped}",
        "/#{escaped}/vote",
        "/#{escaped}/votes/edit",
        "/#{escaped}/event.ics",
        "/#{escaped}/p/token",
        "/#{escaped}/admin/token",
        "/#{escaped}/admin/token/edit"
      ].each do |path|
        get path

        assert_response :not_found, "expected 404 for GET #{path}"
      end
    end

    test "write routes for #{id} are not found" do
      escaped = ERB::Util.url_encode(id)

      post "/#{escaped}/votes", params: {vote: {name: "Carol"}}
      assert_response :not_found

      patch "/#{escaped}/votes", params: {vote: {name: "Carol"}}
      assert_response :not_found

      post "/#{escaped}/admin/token/close"
      assert_response :not_found

      delete "/#{escaped}/admin/token"
      assert_response :not_found
    end
  end

  test "an id of another kind of record is not a poll" do
    get "/poll_#{poll_participants(:alice_one).to_param.delete_prefix("part_")}"

    assert_response :not_found
  end
end
