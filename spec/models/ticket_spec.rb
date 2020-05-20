# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ticket, type: :model do
  describe '.create' do
    let(:ticket) { Ticket.new }
    context 'with token' do
      it 'is set on create' do
        expect(ticket.token).to eq(nil)

        ticket.save!
        expect(ticket.token).not_to eq(nil)
      end
    end

    context 'with status' do
      it 'is set on create' do
        expect(ticket.status).to eq(nil)

        ticket.save!
        expect(ticket.status).to eq(Ticket::STATUSES[:open])
      end
    end

    context 'with checked_at' do
      it 'is set on create' do
        time = Time.now.change(usec: 0)
        allow(Time).to receive(:now).and_return(time)
        expect(ticket.checked_at).to eq(nil)
        ticket.save!
        expect(ticket.checked_at).to eq(time)
      end
    end
  end

  describe '.now_serving' do
    let!(:first_ticket) { Ticket.create }
    let!(:second_ticket) { Ticket.create }
    let!(:third_ticket) { Ticket.create }

    it 'shows the next available ticket' do
      first_ticket.close!
      expect(Ticket.now_serving).to eq(second_ticket)

      second_ticket.skip!
      expect(Ticket.now_serving).to eq(third_ticket)
    end

    context 'when next available has responded' do
      it 'shows the next available ticket' do
        first_ticket.close!
        second_ticket.got_response!
        expect(Ticket.now_serving).to eq(second_ticket)
      end
    end
  end

  describe '#skip!' do
    let(:ticket) { Ticket.create }

    it 'is set as skipped' do
      ticket.skip!

      expect(ticket.status).to eq(Ticket::STATUSES[:closed])
      expect(ticket.closure_code).to eq(Ticket::CLOSURE_CODES[:skipped])
    end
  end

  describe '#got_response!' do
    let(:ticket) { Ticket.create }

    it 'is set as responded' do
      ticket.got_response!

      expect(ticket.status).to eq(Ticket::STATUSES[:responded])
      expect(ticket.closure_code).to eq(nil)
    end
  end

  describe '#close!' do
    let(:ticket) { Ticket.create }

    it 'is set as skipped' do
      ticket.close!

      expect(ticket.status).to eq(Ticket::STATUSES[:closed])
      expect(ticket.closure_code).to eq(Ticket::CLOSURE_CODES[:submitted])
    end
  end

  describe '#responded?' do
    let(:ticket) { Ticket.create }

    context 'when status is set to responded' do
      it 'is true' do
        ticket.status = Ticket::STATUSES[:responded]
        ticket.save!

        expect(ticket.responded?).to eq(true)
      end
    end

    context 'when status is not set to responded' do
      it 'is false' do
        expect(ticket.responded?).to eq(false)
      end
    end
  end

  describe '#closed?' do
    let(:ticket) { Ticket.create }

    context 'when status is set to closed' do
      it 'is true' do
        ticket.status = Ticket::STATUSES[:closed]
        ticket.save!

        expect(ticket.closed?).to eq(true)
      end
    end

    context 'when status is not set to closed' do
      it 'is false' do
        expect(ticket.closed?).to eq(false)
      end
    end
  end

  describe '#submitted?' do
    let(:ticket) { Ticket.create }

    context 'when closure_code is set to submitted' do
      it 'is true' do
        ticket.status = Ticket::STATUSES[:closed]
        ticket.closure_code = Ticket::CLOSURE_CODES[:submitted]
        ticket.save!

        expect(ticket.submitted?).to eq(true)
      end
    end

    context 'when closure_code is not set to submitted' do
      it 'is false' do
        expect(ticket.submitted?).to eq(false)
      end
    end
  end
end
