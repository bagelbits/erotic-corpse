# frozen_string_literal: true

class TicketCalledTimeoutJob < ApplicationJob
  queue_as :default

  def perform(ticket_id)
    # Marks all tickets as skipped if checked_at is more than 10 seconds ago.
    abandoned_tickets = Ticket.where("checked_at < '#{10.seconds.ago}' AND status != '#{Ticket::STATUSES[:closed]}'")
    abandoned_tickets.each(&:skip!)

    # Marks ticket as skipped if not responded
    ticket = Ticket.find(ticket_id)
    return if ticket.responded? || ticket.submitted?

    ticket.skip!
  end
end
