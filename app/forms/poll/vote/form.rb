# frozen_string_literal: true

class Poll
  class Vote
    # Saves one participant's answers to a poll. Creates the participant on the
    # first vote and replaces their answers on later ones, in one transaction.
    class Form
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations

      attribute :name, :string
      attribute :email, :string
      attribute :responses, default: {}

      validates :name, presence: true, length: {minimum: 2, maximum: 50}
      validates :email, format: {with: URI::MailTo::EMAIL_REGEXP}, allow_blank: true

      validate :responses_for_all_options
      validate :valid_response_values

      attr_reader :poll, :participant

      def initialize(attributes = {}, poll:, participant: nil)
        super(attributes)

        @poll = poll
        @participant = participant
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          @participant ||= poll.participants.build
          participant.update!(name: name, email: email.presence)
          participant.votes.delete_all
          participant.votes.create!(votes_attributes)
        end

        true
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:base, e.message)

        false
      end

      private

      def options_by_eid
        @_options_by_eid ||= poll.options.index_by(&:exid_value)
      end

      def normalized_responses
        responses.to_h.transform_keys(&:to_s)
      end

      def responses_for_all_options
        missing = options_by_eid.keys - normalized_responses.keys
        return if missing.empty?

        errors.add(:responses, "must include a response for all proposed dates")
      end

      def valid_response_values
        invalid = normalized_responses.values - Poll::Vote::RESPONSES
        return if invalid.empty?

        errors.add(:responses, "must be 'yes', 'maybe', or 'no'")
      end

      def votes_attributes
        normalized_responses.filter_map do |option_eid, response|
          option = options_by_eid[option_eid]
          next unless option

          {poll: poll, option: option, response: response}
        end
      end
    end
  end
end
