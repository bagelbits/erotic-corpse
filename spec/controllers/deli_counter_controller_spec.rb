# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeliCounterController do
  describe '#ticket' do
    let(:ticket) {Ticket.create}
    it 'generates a ticket' do
      allow(Ticket).to receive(:create).and_return(ticket)
      expect(Ticket).to receive(:create)

      post :ticket
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['ticket']).to eq(ticket.id)
      expect(JSON.parse(response.body)['token']).to eq(ticket.token)
    end

    context 'when ticket is now being served' do
      # TODO: ActionCable testing
    end
  end
end
