# frozen_string_literal: true

require "test_helper"

class Poll::UpdateFormTest < ActiveSupport::TestCase
  setup do
    @poll = polls(:one)
    @morning = poll_options(:morning_meeting)
    @afternoon = poll_options(:afternoon_meeting)
    @evening = poll_options(:evening_meeting)
  end

  test "updates the title, description and deadline" do
    day = 10.days.from_now.to_date

    form = build(event: "Renamed offsite", description: "New plan", end_voting_at: day.iso8601)

    assert form.save, form.errors.full_messages.to_sentence
    assert_equal "Renamed offsite", @poll.name
    assert_equal "New plan", @poll.description
    assert_equal day, @poll.end_voting_at.to_date
  end

  test "keeps options and their votes when they stay" do
    assert_no_difference -> { Poll::Vote.count } do
      assert build.save
    end

    assert_equal [@morning, @afternoon, @evening], @poll.options.to_a
  end

  test "removing an option deletes its votes" do
    form = build(options: current_options.first(2))

    assert_difference -> { Poll::Vote.count }, -1 do
      assert form.save
    end

    assert_not Poll::Option.exists?(@evening.id)
  end

  test "adding an option keeps existing votes" do
    new_option = {date: 3.weeks.from_now.to_date.iso8601, time: "", duration_minutes: 1440}

    assert_no_difference -> { Poll::Vote.count } do
      assert build(options: current_options + [new_option]).save
    end

    assert_equal 4, @poll.options.count
  end

  test "changing only the duration keeps the option and its votes" do
    options = current_options
    options[0] = options[0].merge(duration_minutes: 120)

    assert_no_difference -> { Poll::Vote.count } do
      assert build(options: options).save
    end

    assert_equal 120, @morning.reload.duration_minutes
  end

  test "removing the chosen final date reopens the poll" do
    @poll.close!(@evening)

    assert build(options: current_options.first(2)).save
    assert_not @poll.closed?
    assert_nil @poll.final_option
  end

  test "needs at least two options" do
    form = build(options: current_options.first(1))

    assert_not form.save
    assert_includes form.errors[:options], "must include at least 2 dates or times for voting"
  end

  test "rejects a new deadline in the past but keeps an already passed one" do
    assert_not build(end_voting_at: 3.days.ago.to_date.iso8601).valid?

    @poll.update_columns(end_voting_at: 2.days.ago.end_of_day)
    assert build(end_voting_at: 2.days.ago.to_date.iso8601).valid?
  end

  private

  def current_options
    @poll.options.map do |option|
      local = option.start.in_time_zone(@poll.zone)
      {date: local.to_date.iso8601, time: local.strftime("%H:%M"), duration_minutes: option.duration_minutes}
    end
  end

  def build(**overrides)
    attributes = {
      event: @poll.name,
      description: @poll.description,
      end_voting_at: @poll.end_voting_at.to_date.iso8601,
      options: current_options
    }.merge(overrides)

    Poll::UpdateForm.new(attributes, poll: @poll)
  end
end
