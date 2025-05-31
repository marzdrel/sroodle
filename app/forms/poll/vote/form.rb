# frozen_string_literal: true

class Poll
  class Vote
    class Form
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations

      def initialize(attributes, current_user:)
        super(attributes)
        @current_user = current_user
      end

      attribute :name, :string
      attribute :email, :string
      attribute :responses, default: {}
      attribute :poll_id, :string

      validates :name, presence: true, length: {minimum: 2, maximum: 50}
      validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}

      validate :responses_for_all_options
      validate :valid_response_values

      attr_accessor :current_user, :votes

      def poll
        @_poll ||= Poll.exid_loader(poll_id)
      end

      def responses_for_all_options
        poll_option_ids = poll.options.map(&:exid_value)
        response_option_ids = responses.keys.map(&:to_s)

        missing_responses = poll_option_ids - response_option_ids
        return unless missing_responses.any?

        errors.add(:responses, "must include a response for all proposed dates")
      end

      def valid_response_values
        invalid_responses = responses.values.reject { |value| %w[yes maybe no].include?(value) }

        return unless invalid_responses.any?

        errors.add(:responses, "must be 'yes', 'maybe', or 'no'")
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          self.votes = current_user.votes.create!(votes_attributes)
        end

        true
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:base, e.message)
        false
      end

      private

      def votes_attributes
        responses.map do |option_eid, response|
          {
            option: poll.options.exid_loader(option_eid),
            response: response,
            eid: UUID7.generate,
            poll: poll
          }
        end
      end

      # def find_or_create_user
      #   user = User.find_by(email: email)
      #   return user if user
      #
      #   password = SecureRandom.hex(8)
      #   User.create!(email: email, password: password, status: "pending")
      # end
    end
  end
end
