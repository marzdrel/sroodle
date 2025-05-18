class Poll < ApplicationRecord
  belongs_to :creator, class_name: "User"

  validates(
    :name,
    presence: true,
    length: { minimum: 5, maximum: 100 },
  )
end
