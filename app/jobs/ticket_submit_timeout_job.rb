# frozen_string_literal: true

class TicketSubmitTimeoutJob < ApplicationJob
  queue_as :default

  def perform(ticket_id)
    ticket = Ticket.find(ticket_id)
    return if ticket.closed?

    ticket.skip!
  end
end
