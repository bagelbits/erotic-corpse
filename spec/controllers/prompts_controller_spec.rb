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
  end

  describe '#report' do
    let(:prompt) { build(:prompt) }
    let(:ticket) { build(:ticket) }
    it 'marks prompt as reported' do
      allow(Prompt).to receive(:find).and_return(prompt)
      allow_any_instance_of(Prompt).to receive(:report!)

      expect_any_instance_of(Prompt).to receive(:report!)
      post :report, params: { id: 2, ticket: ticket.id, token: ticket.token }

      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['success']).to eq(true)
      expect(JSON.parse(response.body)['error']).to eq('')
    end

    context 'with ActiveRecord::RecordInvalid' do
      it 'responds with error' do
        allow(Prompt).to receive(:find).and_return(prompt)
        allow_any_instance_of(Prompt).to receive(:report!).and_raise(
          ActiveRecord::RecordInvalid
        )

        expect_any_instance_of(Prompt).to receive(:report!)
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
  end
end
