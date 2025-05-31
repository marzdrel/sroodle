# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20250531133418
#
# Table name: users
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  status             :string           not null
#
# Indexes
#
#  index_users_on_confirmation_token  (confirmation_token) UNIQUE
#  index_users_on_email               (email)
#  index_users_on_remember_token      (remember_token) UNIQUE
#
# rubocop:enable Layout/LineLength

class User < ApplicationRecord
  include Clearance::User

  enum(
    :status,
    {
      pending: "pending",
      active: "active",
      blocked: "blocked"
    }
  )

  has_many :votes, class_name: "Poll::Vote", dependent: :destroy

  accepts_nested_attributes_for :votes
end
