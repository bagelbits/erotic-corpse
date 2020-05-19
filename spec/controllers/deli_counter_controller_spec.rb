# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeliCounterController do
  describe '#ticket' do
    let(:ticket) { Ticket.create }
    it 'generates a ticket' do
      allow(Ticket).to receive(:create).and_return(ticket)
      expect(Ticket).to receive(:create)

      post :ticket
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
      expect(JSON.parse(response.body)['token']).to eq(ticket.token)
    end

    context 'when ticket is now being served' do
      # TODO: ActiveJob testing
    end
  end

  describe '#now_serving' do
    let(:ticket) { build(:ticket) }
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

        post :now_serving, params: { ticket: calling_ticket.id, token: calling_ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end
  end
end
