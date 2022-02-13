# frozen_string_literal: true

describe DeliCounterController do
  describe '#ticket' do
    let(:ticket) { create(:ticket) }
    let(:now_serving_ticket) { create(:ticket) }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'generates a ticket' do
      allow(Ticket).to receive(:create).and_return(ticket)
      allow(Ticket).to receive(:now_serving).and_return(now_serving_ticket)

      post :ticket
      expect(Ticket).to have_received(:create)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
      expect(JSON.parse(response.body)['token']).to eq(ticket.token)
      expect(TicketCalledTimeoutJob).not_to have_been_enqueued
    end

    context 'when ticket is now being served' do
      it 'also triggers ActiveJob' do
        allow(Ticket).to receive(:create).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)

        post :ticket
        expect(Ticket).to have_received(:create)
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
        expect(JSON.parse(response.body)['token']).to eq(ticket.token)
        expect(TicketCalledTimeoutJob).to have_been_enqueued.with(ticket.id)
      end
    end
  end

  describe '#now_serving' do
    let(:ticket) { create(:ticket, checked_at: Time.zone.now) }
    let(:calling_ticket) { create(:ticket) }

    before do
      allow(Ticket).to receive(:now_serving).and_return(ticket)
    end

    it 'gives the ticket now being served' do
      allow(Ticket).to receive(:where).and_return([calling_ticket])

      post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

      expect(Ticket).to have_received(:now_serving)
      expect(Ticket).to have_received(:where)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
    end

    context 'when calling ticket does not exist' do
      it 'does nothing' do
        allow(Ticket).to receive(:where).and_return([])

        post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

        expect(Ticket).to have_received(:where)
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when token does not match ticket' do
      let(:fake_ticket) { build(:ticket, id: calling_ticket.id, token: SecureRandom.uuid) }

      it 'does nothing' do
        allow(Ticket).to receive(:where).and_return([calling_ticket])

        post :now_serving, params: { ticket: fake_ticket.id, token: fake_ticket.token }

        expect(Ticket).to have_received(:where)
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when there is no now_serving' do
      let(:ticket) { nil }

      it 'does nothing' do
        post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

        expect(Ticket).to have_received(:now_serving)
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when ticket is old' do
      let(:ticket) { create(:ticket) }

      before do
        ticket.checked_at = 20.seconds.ago
        ticket.save!
      end

      it 'clears it out and gets a new ticket' do
        allow(Ticket).to receive(:where).and_return([calling_ticket])
        allow(TicketCalledTimeoutJob).to receive(:perform_now)

        post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

        expect(TicketCalledTimeoutJob).to have_received(:perform_now).with(ticket.id)
        expect(Ticket).to have_received(:now_serving).twice
        expect(Ticket).to have_received(:where)
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
      end
    end
  end

  describe '#heartbeat' do
    let(:ticket) { create(:ticket) }

    it 'checks in the ticket' do
      allow(Ticket).to receive(:find).and_return(ticket)
      allow(ticket).to receive(:check_in!)

      post :heartbeat, params: { ticket: ticket.id, token: ticket.token }

      expect(Ticket).to have_received(:find)
      expect(ticket).to have_received(:check_in!)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['success']).to eq(true)
    end

    context 'when ticket is closed' do
      let(:ticket) { create(:ticket, status: Ticket::STATUSES[:closed]) }

      it 'does nothing' do
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(ticket).to receive(:check_in!)

        post :heartbeat, params: { ticket: ticket.id, token: ticket.token }

        expect(Ticket).to have_received(:find)
        expect(ticket).not_to have_received(:check_in!)
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
      end
    end
  end
end
