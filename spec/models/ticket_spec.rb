# frozen_string_literal: true

describe Ticket, type: :model do
  describe '.create' do
    let(:ticket) { build(:ticket) }

    context 'with token' do
      it 'is set on create' do
        expect(ticket.token).to eq(nil)

        ticket.save!
        expect(ticket.token).not_to eq(nil)
      end
    end

    context 'with checked_at' do
      it 'is set on create' do
        time = Time.zone.now.change(usec: 0)
        allow(Time).to receive(:now).and_return(time)
        expect(ticket.checked_at).to eq(nil)
        ticket.save!
        expect(ticket.checked_at).to eq(time)
      end
    end
  end

  describe '.now_serving' do
    let!(:first_ticket) { create(:ticket) }
    let!(:second_ticket) { create(:ticket) }
    let!(:third_ticket) { create(:ticket) }

    it 'shows the next available ticket' do
      first_ticket.close!
      expect(described_class.now_serving).to eq(second_ticket)

      second_ticket.skip!
      expect(described_class.now_serving).to eq(third_ticket)
    end

    context 'when next available has responded' do
      it 'shows the next available ticket' do
        first_ticket.close!
        second_ticket.got_response!
        expect(described_class.now_serving).to eq(second_ticket)
      end
    end
  end

  describe '#check_in!' do
    let(:ticket) { create(:ticket) }

    it 'updates checked_at' do
      time_now = Time.zone.now.change(usec: 0)
      time_future = Time.zone.now.change(usec: 0) + 5.minutes

      allow(Time).to receive(:now).and_return(time_now)
      expect(ticket.checked_at).to eq(time_now)
      allow(Time).to receive(:now).and_return(time_future)
      ticket.check_in!
      expect(ticket.checked_at).to eq(time_future)
    end
  end

  describe '#skip!' do
    let(:ticket) { create(:ticket) }

    it 'is set as skipped' do
      ticket.skip!

      expect(ticket.status).to eq(Ticket::STATUSES[:closed])
      expect(ticket.closure_code).to eq(Ticket::CLOSURE_CODES[:skipped])
    end
  end

  describe '#got_response!' do
    let(:ticket) { create(:ticket) }

    it 'is set as responded' do
      ticket.got_response!

      expect(ticket.status).to eq(Ticket::STATUSES[:responded])
      expect(ticket.closure_code).to eq(nil)
    end
  end

  describe '#close!' do
    let(:ticket) { create(:ticket) }

    it 'is set as skipped' do
      ticket.close!

      expect(ticket.status).to eq(Ticket::STATUSES[:closed])
      expect(ticket.closure_code).to eq(Ticket::CLOSURE_CODES[:submitted])
    end
  end

  describe '#responded?' do
    let(:ticket) { create(:ticket) }

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
    let(:ticket) { create(:ticket) }

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
    let(:ticket) { create(:ticket) }

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
