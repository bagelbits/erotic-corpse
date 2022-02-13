# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeliCounterController do
  describe '#ticket' do
    let(:ticket) { build(:ticket) }
    let(:now_serving_ticket) { build(:ticket) }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'generates a ticket' do
      allow(Ticket).to receive(:create).and_return(ticket)
      allow(Ticket).to receive(:now_serving).and_return(now_serving_ticket)
      expect(Ticket).to receive(:create)

      post :ticket
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
      expect(JSON.parse(response.body)['token']).to eq(ticket.token)
      expect(TicketCalledTimeoutJob).not_to have_been_enqueued
    end

    context 'when ticket is now being served' do
      it 'also triggers ActiveJob' do
        allow(Ticket).to receive(:create).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)
        expect(Ticket).to receive(:create)

        post :ticket
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
        expect(JSON.parse(response.body)['token']).to eq(ticket.token)
        expect(TicketCalledTimeoutJob).to have_been_enqueued.with(ticket.id)
      end
    end
  end

  describe '#now_serving' do
    let(:ticket) { build(:ticket, checked_at: Time.zone.now) }
    let(:calling_ticket) { build(:ticket) }

    before do
      allow(Ticket).to receive(:now_serving).and_return(ticket)
    end

    it 'gives the ticket now being served' do
      allow(Ticket).to receive(:where).and_return([calling_ticket])
      expect(Ticket).to receive(:now_serving)
      expect(Ticket).to receive(:where)

      post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
    end

    context 'when calling ticket does not exist' do
      it 'does nothing' do
        allow(Ticket).to receive(:where).and_return([])
        expect(Ticket).to receive(:where)

        post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when token does not match ticket' do
      let(:fake_ticket) { build(:ticket, id: calling_ticket.id) }

      it 'does nothing' do
        allow(Ticket).to receive(:where).and_return([calling_ticket])
        expect(Ticket).to receive(:where)

        post :now_serving, params: { ticket: fake_ticket.id, token: fake_ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when there is no now_serving' do
      let(:ticket) { nil }

      it 'does nothing' do
        expect(Ticket).to receive(:now_serving)

        post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when ticket is old' do
      let(:ticket) { build(:ticket, checked_at: 20.seconds.ago) }

      it 'clears it out and gets a new ticket' do
        allow(Ticket).to receive(:where).and_return([calling_ticket])
        allow(TicketCalledTimeoutJob).to receive(:perform_now)
        expect(Ticket).to receive(:now_serving)
        expect(Ticket).to receive(:where)
        expect(TicketCalledTimeoutJob).to receive(:perform_now).with(ticket.id)

        post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
      end
    end
  end

  describe '#heartbeat' do
    let(:ticket) { build(:ticket) }

    it 'checks in the ticket' do
      allow(Ticket).to receive(:find).and_return(ticket)
      allow(ticket).to receive(:check_in!)
      expect(Ticket).to receive(:find)
      expect(ticket).to receive(:check_in!)

      post :heartbeat, params: { ticket: ticket.id, token: ticket.token }

      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['success']).to eq(true)
    end

    context 'when ticket is closed' do
      let(:ticket) { build(:ticket, status: Ticket::STATUSES[:closed]) }

      it 'does nothing' do
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(ticket).to receive(:check_in!)
        expect(Ticket).to receive(:find)
        expect(ticket).not_to receive(:check_in!)

        post :heartbeat, params: { ticket: ticket.id, token: ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
      end
    end
  end
end
