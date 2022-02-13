# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TicketSubmitTimeoutJob, type: :job do
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

  context 'when ticket is closed' do
    it 'will do nothing' do
      ticket.close!

      expect(Ticket).to receive(:find).with(ticket.id)
      expect(ticket).not_to receive(:skip!)
      described_class.perform_now(ticket.id)
    end
  end
end
