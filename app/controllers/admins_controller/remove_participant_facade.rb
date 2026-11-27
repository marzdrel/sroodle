# frozen_string_literal: true

class AdminsController
  # Removes one participant and their answers, e.g. spam or a duplicate.
  class RemoveParticipantFacade
    include FindPoll

    def self.call(...)
      new(...).call
    end

    def initialize(params)
      self.params = params
    end

    def call
      participant = Poll::Participant.exid_loader(params.fetch(:participant_id))
      raise ActiveRecord::RecordNotFound unless participant.poll_id == poll.id

      participant.destroy!

      FacadeResult.new(success?: true, data: {admin_path: admin_path, name: participant.name})
    end

    private

    attr_accessor :params
  end
end
