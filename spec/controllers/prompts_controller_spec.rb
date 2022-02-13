# frozen_string_literal: true

describe PromptsController do
  describe '#create' do
    it 'creates and links the prompts' do
      last_prompt = create(:prompt, prompt: 'This is a test')
      ticket = create(:ticket)
      post :create,
           params: { prompt: 'Lorem ipsum test', previous_prompt_id: last_prompt.id, ticket: ticket.id,
                     token: ticket.token, }

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
        end.to raise_error(ActionController::ParameterMissing,
                           'param is missing or the value is empty: previous_prompt_id')
      end
    end
  end

  describe '#story' do
    let(:third_prompt) { build(:prompt, prompt: 'This is a test 3') }
    let(:second_prompt) do
      build(:prompt, prompt: 'This is a test 2', next_prompt: third_prompt.id)
    end
    let(:first_prompt) do
      build(:prompt, prompt: 'This is a test 1', next_prompt: second_prompt.id)
    end

    let(:full_story) do
      [
        { prompt: first_prompt.prompt, reported: first_prompt.reported },
        { prompt: second_prompt.prompt, reported: second_prompt.reported },
        { prompt: third_prompt.prompt, reported: third_prompt.reported },
      ]
    end
    let(:ticket) { create(:ticket) }

    it 'gives the full story' do
      allow(Prompt).to receive(:full_story).and_return(full_story)
      allow(Ticket).to receive(:find).and_return(ticket)
      allow(ticket).to receive(:closed?).and_return(true)

      get :story, params: { ticket: ticket.id, token: ticket.token }
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['full_story']).to eq(full_story.map(&:stringify_keys))

      expect(Ticket).to have_received(:find)
      expect(ticket).to have_received(:closed?)
      expect(Prompt).to have_received(:full_story)
    end

    context 'with missing ticket' do
      it 'fails' do
        expect do
          get :story, params: { token: 'token' }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: ticket')
      end
    end

    context 'with missing token' do
      it 'fails' do
        expect do
          get :story, params: { ticket: 1 }
        end.to raise_error(ActionController::ParameterMissing, 'param is missing or the value is empty: token')
      end
    end

    context 'when ticket is not closed' do
      it 'returns nothing' do
        allow(Prompt).to receive(:full_story).and_return(full_story)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(ticket).to receive(:closed?).and_return(false)

        get :story, params: { ticket: ticket.id, token: ticket.token }
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})

        expect(Ticket).to have_received(:find)
        expect(ticket).to have_received(:closed?)
        expect(Prompt).not_to have_received(:full_story)
      end
    end

    context 'when token does not match ticket' do
      let(:fake_ticket) { build(:ticket, id: ticket.id, token: SecureRandom.uuid) }

      it 'returns nothing' do
        allow(Prompt).to receive(:full_story).and_return(full_story)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(ticket).to receive(:closed?).and_return(true)

        get :story, params: { ticket: ticket.id, token: fake_ticket.token }
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})

        expect(Ticket).to have_received(:find)
        expect(ticket).to have_received(:closed?)
        expect(Prompt).not_to have_received(:full_story)
      end
    end
  end

  describe '#last' do
    let(:prompt) { build(:prompt) }
    let(:ticket) { create(:ticket) }

    before do
      ActiveJob::Base.queue_adapter = :test
    end

    it 'gives the last Prompt' do
      allow(Prompt).to receive(:last_prompt).and_return(prompt)
      allow(Ticket).to receive(:find).and_return(ticket)
      allow(Ticket).to receive(:now_serving).and_return(ticket)
      allow(ticket).to receive(:got_response!)
      allow(ticket).to receive(:check_in!)

      get :last, params: { ticket: ticket.id, token: ticket.token }
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['id']).to eq(prompt.id)
      expect(TicketSubmitTimeoutJob).to have_been_enqueued.with(ticket.id)

      expect(Prompt).to have_received(:last_prompt)
      expect(Ticket).to have_received(:find)
      expect(ticket).to have_received(:got_response!)
      expect(ticket).to have_received(:check_in!)
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
        allow(ticket).to receive(:got_response!)
        allow(ticket).to receive(:check_in!)

        get :last, params: { ticket: ticket.id, token: ticket.token }
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})

        expect(Ticket).to have_received(:find)
        expect(Prompt).not_to have_received(:last_prompt)
        expect(ticket).not_to have_received(:got_response!)
        expect(ticket).not_to have_received(:check_in!)
      end
    end

    context 'when token does not match ticket' do
      let(:fake_ticket) { build(:ticket, id: ticket.id, token: SecureRandom.uuid) }

      it 'does nothing' do
        allow(Prompt).to receive(:last_prompt).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)
        allow(ticket).to receive(:got_response!)
        allow(ticket).to receive(:check_in!)

        get :last, params: { ticket: fake_ticket.id, token: fake_ticket.token }
        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)).to eq({})

        expect(Ticket).to have_received(:find)
        expect(Prompt).not_to have_received(:last_prompt)
        expect(ticket).not_to have_received(:got_response!)
        expect(ticket).not_to have_received(:check_in!)
      end
    end
  end

  describe '#report' do
    let(:prompt) { build(:prompt) }
    let(:ticket) { create(:ticket) }

    it 'marks prompt as reported' do
      allow(Prompt).to receive(:find).and_return(prompt)
      allow(Ticket).to receive(:find).and_return(ticket)
      allow(Ticket).to receive(:now_serving).and_return(ticket)
      allow(prompt).to receive(:report!)

      post :report, params: { id: 2, ticket: ticket.id, token: ticket.token }

      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['success']).to eq(true)
      expect(JSON.parse(response.body)['error']).to eq('')

      expect(Ticket).to have_received(:find)
      expect(Ticket).to have_received(:now_serving)
      expect(prompt).to have_received(:report!)
    end

    context 'with ActiveRecord::RecordInvalid' do
      it 'responds with error' do
        allow(Prompt).to receive(:find).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)
        allow(prompt).to receive(:report!).and_raise(
          ActiveRecord::RecordInvalid
        )
        post :report, params: { id: 2, ticket: ticket.id, token: ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['error']).to eq(
          "Unfortunately, we can't roll back the story anymore. Sorry for the inconvience."
        )

        expect(Ticket).to have_received(:find)
        expect(Ticket).to have_received(:now_serving)
        expect(prompt).to have_received(:report!)
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
        allow(prompt).to receive(:report!)
        post :report, params: { id: 2, ticket: ticket.id, token: ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['error']).to eq("Unfortunately, you shouldn't have that ticket")

        expect(Ticket).to have_received(:find)
        expect(Ticket).to have_received(:now_serving)
        expect(prompt).not_to have_received(:report!)
      end
    end

    context 'when token does not match ticket' do
      let(:fake_ticket) { build(:ticket, id: ticket.id, token: SecureRandom.uuid) }

      it 'does nothing' do
        allow(Prompt).to receive(:find).and_return(prompt)
        allow(Ticket).to receive(:find).and_return(ticket)
        allow(Ticket).to receive(:now_serving).and_return(ticket)
        allow(prompt).to receive(:report!)
        post :report, params: { id: 2, ticket: fake_ticket.id, token: fake_ticket.token }

        expect(response.code).to eq('200')
        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['error']).to eq("Unfortunately, you shouldn't have that ticket")

        expect(Ticket).to have_received(:find)
        expect(Ticket).to have_received(:now_serving)
        expect(prompt).not_to have_received(:report!)
      end
    end
  end
end
