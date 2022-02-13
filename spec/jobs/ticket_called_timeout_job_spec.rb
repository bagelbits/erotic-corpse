# frozen_string_literal: true

describe TicketCalledTimeoutJob, type: :job do
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

  context 'when ticket responded' do
    it 'will do nothing' do
      ticket.status = Ticket::STATUSES[:responded]
      ticket.save!

      described_class.perform_now(ticket.id)
      expect(Ticket).to have_received(:find).with(ticket.id)
      expect(ticket).not_to have_received(:skip!)
    end
  end

  context 'when ticket is closed' do
    it 'will do nothing' do
      ticket.close!

      described_class.perform_now(ticket.id)
      expect(Ticket).to have_received(:find).with(ticket.id)
      expect(ticket).not_to have_received(:skip!)
    end
  end

  context 'with other tickets that are abandoned' do
    let(:abandoned_ticket_1) { Ticket.create(checked_at: 12.seconds.ago) }
    let(:abandoned_ticket_2) { Ticket.create(checked_at: 1.minute.ago) }
    let(:abandoned_tickets) { [abandoned_ticket_1, abandoned_ticket_2] }

    before do
      allow(abandoned_ticket_1).to receive(:skip!)
      allow(abandoned_ticket_2).to receive(:skip!)
    end

    it 'will close them' do
      allow(Ticket).to receive(:where).and_return(abandoned_tickets)
      described_class.perform_now(ticket.id)

      expect(abandoned_tickets).to all(have_received(:skip!))
      expect(Ticket).to have_received(:find).with(ticket.id)
      expect(ticket).to have_received(:skip!)
    end
  end
end
