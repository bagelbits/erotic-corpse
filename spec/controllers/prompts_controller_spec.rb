# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptsController do
  describe '#index' do
    let(:prompts) { build_list(:prompt, 3) }
    it 'gives a list of prompts' do
      allow(Prompt).to receive(:all).and_return(prompts)
      expect(Prompt).to receive(:all)

      get :index
      expect(response.code).to eq('200')
      expect(response.body).to eq(prompts.to_json)
    end
  end

  describe '#create' do
    it 'creates and links the prompts' do
      last_prompt = Prompt.create(prompt: 'This is a test')
      post :create, params: { prompt: 'Lorem ipsum', previous_prompt_id: last_prompt.id }

      last_prompt = Prompt.find(last_prompt.id)
      expect(response.code).to eq('200')
      expect(last_prompt.next_prompt).to eq(JSON.parse(response.body)['id'])
    end
  end

  describe '#last' do
    let(:prompt) { build(:prompt) }
    it 'gives the last Prompt' do
      allow(Prompt).to receive(:last_prompt).and_return(prompt)
      expect(Prompt).to receive(:last_prompt).and_return(prompt)

      get :last
      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['id']).to eq(prompt.id)
    end
  end

  describe '#report' do
    let(:prompt) { build(:prompt) }
    it 'marks prompt as reported' do
      allow(Prompt).to receive(:find).and_return(prompt)
      allow_any_instance_of(Prompt).to receive(:report!)

      expect_any_instance_of(Prompt).to receive(:report!)
      post :report, params: { id: 2 }

      expect(response.code).to eq('200')
      expect(JSON.parse(response.body)['id']).to eq(prompt.id)
    end
  end
end
