class Poll < ApplicationRecord
  include Exid::Record.new("poll", :eid)

  belongs_to :creator, class_name: "User"

  validates(
    :name,
    presence: true,
    length: {minimum: 5, maximum: 100}
  )

  def to_param = exid_value
end
