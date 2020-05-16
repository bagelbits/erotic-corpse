# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PromptsController do
  describe '#index' do
    it 'gives a list of prompts' do
    end
  end

  describe '#create' do
  end

  describe '#last' do
    it 'gives the last Prompt without a next_prompt' do
    end

    context 'if prompted is reported' do
      it 'is ignored' do
      end
    end
  end

  describe '#report' do
    let(:prompt) { build(:prompt) }
    it 'marks prompt as reported' do
      allow(Prompt).to receive(:find).and_return(prompt)
      allow_any_instance_of(Prompt).to receive(:report!)

      expect_any_instance_of(Prompt).to receive(:report!)
      post :report, params: { id: 2 }
    end
  end
end
