# frozen_string_literal: true

# Fills in the UUIDv7 `eid` column that Exid uses for external IDs.
module GeneratesEid
  extend ActiveSupport::Concern

  included do
    before_validation { self.eid ||= UUID7.generate }
  end
end
