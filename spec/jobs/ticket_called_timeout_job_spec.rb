# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TicketCalledTimeoutJob, type: :job do
  let(:ticket) { Ticket.create }

  before do
    allow(Ticket).to receive(:find).and_return(ticket)
    allow_any_instance_of(Ticket).to receive(:skip!)
  end

  it 'will skip the ticket' do
    expect(Ticket).to receive(:find).with(ticket.id)
    expect(ticket).to receive(:skip!)
    described_class.perform_now(ticket.id)
  end

  context 'when ticket responded' do
    it 'will do nothing' do
      ticket.status = Ticket::STATUSES[:responded]
      ticket.save!

      expect(Ticket).to receive(:find).with(ticket.id)
      expect(ticket).not_to receive(:skip!)
      described_class.perform_now(ticket.id)
    end
  end

  context 'when ticket is closed' do
    it 'will do nothing' do
      ticket.close!

      expect(Ticket).to receive(:find).with(ticket.id)
      expect(ticket).not_to receive(:skip!)
      described_class.perform_now(ticket.id)
    end
  end

  context 'with other tickets that are abandoned' do
    let(:abandoned_ticket_1) { Ticket.create(checked_at: 12.seconds.ago) }
    let(:abandoned_ticket_2) { Ticket.create(checked_at: 1.minute.ago) }
    let(:abandoned_tickets) { [abandoned_ticket_1, abandoned_ticket_2] }

    it 'will close them' do
      allow(Ticket).to receive(:where).and_return(abandoned_tickets)
      abandoned_tickets.each do |ticket|
        expect(ticket).to receive(:skip!)
      end

      expect(Ticket).to receive(:find).with(ticket.id)
      expect(ticket).to receive(:skip!)
      described_class.perform_now(ticket.id)
    end
  end
end
