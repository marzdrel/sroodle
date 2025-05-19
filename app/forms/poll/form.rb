# frozen_string_literal: true

class Poll
  class Form
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveModel::Validations

    attribute :name, :string
    attribute :email, :string
    attribute :event, :string
    attribute :description, :string
    attribute :creator_id, :integer

    validates :name, presence: true, length: { minimum: 2, maximum: 50 }
    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :event, presence: true, length: { minimum: 5, maximum: 100 }
    validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
    validates :creator_id, presence: true

    attr_reader :poll_id

    def save
      return false unless valid?

      ActiveRecord::Base.transaction do
        user = find_or_create_user
        poll = create_poll(user)
        @poll_id = poll.id
      end

      true
    rescue ActiveRecord::RecordInvalid => e
      errors.add(:base, e.message)
      false
    end

    private

    def find_or_create_user
      user = User.find_by(email: email)
      return user if user

      random_password = SecureRandom.hex(8)
      User.create!(email: email, password: random_password)
    end

    def create_poll(user)
      Poll.create!(
        name: event,
        description: description,
        creator: user,
      )
    end
  end
end
