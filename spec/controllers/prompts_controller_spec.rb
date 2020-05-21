# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptsController do
  describe '#create' do
    it 'creates and links the prompts' do
      last_prompt = Prompt.create(prompt: 'This is a test')
      ticket = Ticket.create
      post :create, params: { prompt: 'Lorem ipsum', previous_prompt_id: last_prompt.id, ticket: ticket.id, token: ticket.token }

      last_prompt = Prompt.find(last_prompt.id)
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['id']).to eq(last_prompt.next_prompt)
    end

    context 'with missing ticket' do
      it 'fails' do
        expect do
          post :create, params: { prompt: 'Lorem ipsum', previous_prompt_id: 1, token: 'token' }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: ticket')
      end
    end

    context 'with missing token' do
      it 'fails' do
        expect do
          post :create, params: { prompt: 'Lorem ipsum', previous_prompt_id: 1, ticket: 1 }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: token')
      end
    end

    context 'with missing prompt' do
      it 'fails' do
        expect do
          post :create, params: { previous_prompt_id: 1, ticket: 1, token: 'token' }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: prompt')
      end
    end

    context 'with missing previous_prompt_id' do
      it 'fails' do
        expect do
          post :create, params: { prompt: 'Lorem ipsum', ticket: 1, token: 'token' }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: previous_prompt_id')
      end
    end
  end

  describe '#last' do
    let(:prompt) { build(:prompt) }
    let(:ticket) { build(:ticket) }

    before :each do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'gives the last Prompt' do
      allow(Prompt).to receive(:last_prompt).and_return(prompt)
      allow(Ticket).to receive(:find).and_return(ticket)
      allow(Ticket).to receive(:now_serving).and_return(ticket)
      allow_any_instance_of(Ticket).to receive(:got_response!)
      allow_any_instance_of(Ticket).to receive(:check_in!)

      expect(Prompt).to receive(:last_prompt)
      expect(Ticket).to receive(:find)
      expect(ticket).to receive(:got_response!)
      expect(ticket).to receive(:check_in!)

      get :last, params: { ticket: ticket.id, token: ticket.token }
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['id']).to eq(prompt.id)
      expect(TicketSubmitTimeoutJob).to have_been_enqueued.with(ticket.id)
    end

    context 'with missing ticket' do
      it 'fails' do
        expect do
          get :last, params: { token: 'token' }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: ticket')
        expect(TicketSubmitTimeoutJob).not_to have_been_enqueued.with(ticket.id)
      end
    end

    context 'with missing token' do
      it 'fails' do
        expect do
          get :last, params: { ticket: 1 }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: token')
        expect(TicketSubmitTimeoutJob).not_to have_been_enqueued.with(ticket.id)
      end
    end

    context 'when ticket is not being served' do
      let(:serving_ticket) { build(:ticket) }
      it 'does nothing' do
        allow(Prompt).to receive(:last_prompt).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(serving_ticket)
        allow_any_instance_of(Ticket).to receive(:got_response!)
        allow_any_instance_of(Ticket).to receive(:check_in!)

        expect(Ticket).to receive(:find)
        expect(Prompt).not_to receive(:last_prompt)
        expect(ticket).not_to receive(:got_response!)
        expect(ticket).not_to receive(:check_in!)

        get :last, params: { ticket: ticket.id, token: ticket.token }
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end

    context 'when token does not match ticket' do
      let(:fake_ticket) { build(:ticket, id: ticket.id) }
      it 'does nothing' do
        allow(Prompt).to receive(:last_prompt).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)
        allow_any_instance_of(Ticket).to receive(:got_response!)
        allow_any_instance_of(Ticket).to receive(:check_in!)

        expect(Ticket).to receive(:find)
        expect(Prompt).not_to receive(:last_prompt)
        expect(ticket).not_to receive(:got_response!)
        expect(ticket).not_to receive(:check_in!)

        get :last, params: { ticket: fake_ticket.id, token: fake_ticket.token }
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})
      end
    end
  end

  describe '#report' do
    let(:prompt) { build(:prompt) }
    let(:ticket) { build(:ticket) }
    it 'marks prompt as reported' do
      allow(Prompt).to receive(:find).and_return(prompt)
      allow(Ticket).to receive(:find).and_return(ticket)
      allow(Ticket).to receive(:now_serving).and_return(ticket)
      allow_any_instance_of(Prompt).to receive(:report!)

      expect(Ticket).to receive(:find)
      expect(Ticket).to receive(:now_serving)
      expect(prompt).to receive(:report!)
      post :report, params: { id: 2, ticket: ticket.id, token: ticket.token }

      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['success']).to eq(true)
      expect(JSON.parse(response.body)['error']).to eq('')
    end

    context 'with ActiveRecord::RecordInvalid' do
      it 'responds with error' do
        allow(Prompt).to receive(:find).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)
        allow(prompt).to receive(:report!).and_raise(
          ActiveRecord::RecordInvalid
        )

        expect(Ticket).to receive(:find)
        expect(Ticket).to receive(:now_serving)
        expect(prompt).to receive(:report!)
        post :report, params: { id: 2, ticket: ticket.id, token: ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['error']).to eq(
          "Unfortunately, we can't roll back the story anymore. Sorry for the inconvience."
        )
      end
    end

    context 'with missing ticket' do
      it 'fails' do
        expect do
          post :report, params: { id: 2, token: 'token' }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: ticket')
      end
    end

    context 'with missing token' do
      it 'fails' do
        expect do
          post :report, params: { id: 2, ticket: 1 }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: token')
      end
    end

    context 'when ticket is not being served' do
      let(:serving_ticket) { build(:ticket) }
      it 'does nothing' do
        allow(Prompt).to receive(:find).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(serving_ticket)
        allow_any_instance_of(Prompt).to receive(:report!)

        expect(Ticket).to receive(:find)
        expect(Ticket).to receive(:now_serving)
        expect(prompt).not_to receive(:report!)
        post :report, params: { id: 2, ticket: ticket.id, token: ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['error']).to eq("Unfortunately, you shouldn't have that ticket")
      end
    end

    context 'when token does not match ticket' do
      let(:fake_ticket) { build(:ticket, id: ticket.id) }
      it 'does nothing' do
        allow(Prompt).to receive(:find).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)
        allow_any_instance_of(Prompt).to receive(:report!)

        expect(Ticket).to receive(:find)
        expect(Ticket).to receive(:now_serving)
        expect(prompt).not_to receive(:report!)
        post :report, params: { id: 2, ticket: fake_ticket.id, token: fake_ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['error']).to eq("Unfortunately, you shouldn't have that ticket")
      end
    end
  end
end
