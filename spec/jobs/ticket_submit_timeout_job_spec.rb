# frozen_string_literal: true

describe TicketSubmitTimeoutJob, type: :job do
  let(:ticket) { Ticket.create }

  before do
    allow(Ticket).to receive(:find).and_return(ticket)
    allow(ticket).to receive(:skip!)
  end

  it 'will skip the ticket' do
    described_class.perform_now(ticket.id)

    expect(Ticket).to have_received(:find).with(ticket.id)
    expect(ticket).to have_received(:skip!)
  end

  context 'when ticket is closed' do
    it 'will do nothing' do
      ticket.close!

      described_class.perform_now(ticket.id)
      expect(Ticket).to have_received(:find).with(ticket.id)
      expect(ticket).not_to have_received(:skip!)
    end
  end
end
