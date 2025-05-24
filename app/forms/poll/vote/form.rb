# frozen_string_literal: true

class Poll
  class Vote
    class Form
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Validations

      attribute :name, :string
      attribute :email, :string
      attribute :responses, default: {}
      attribute :poll_id

      validates :name, presence: true, length: {minimum: 2, maximum: 50}
      validates :email, presence: true, format: {with: URI::MailTo::EMAIL_REGEXP}
      validate :responses_for_all_options
      validate :valid_response_values

      attr_reader :votes

      def poll
        @_poll ||= Poll.exid_loader(poll_id)
      end

      def responses_for_all_options
        poll_option_ids = poll.options.pluck(:id).map(&:to_s)
        response_option_ids = responses.keys.map(&:to_s)

        missing_responses = poll_option_ids - response_option_ids
        if missing_responses.any?
          errors.add(:responses, "must include a response for all proposed dates")
        end
      end

      def valid_response_values
        invalid_responses = responses.values.reject { |value| %w[yes maybe no].include?(value) }

        if invalid_responses.any?
          errors.add(:responses, "must be 'yes', 'maybe', or 'no'")
        end
      end

      def save
        return false unless valid?

        ActiveRecord::Base.transaction do
          user = find_or_create_user
          @votes = user.votes.create!(votes_attributes.map { |attrs| attrs.merge(poll: poll) })
        end

        true
      rescue ActiveRecord::RecordInvalid => e
        errors.add(:base, e.message)
        false
      end

      private

      def votes_attributes
        responses.map do |option_id, response|
          option = poll.options.find_by(id: option_id)
          next unless option

          {
            option_id: option.id,
            response: response
          }
        end.compact
      rescue ActiveRecord::RecordNotFound
        errors.add(:responses, "contains invalid option IDs")
      end

      def find_or_create_user
        user = User.find_by(email: email)
        return user if user

        password = SecureRandom.hex(8)
        User.create!(email: email, password: password)
      end
    end
  end
end
