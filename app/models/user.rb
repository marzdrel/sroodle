# rubocop:disable Layout/LineLength
# == Schema Information
# Schema version: 20250519211503
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
end
