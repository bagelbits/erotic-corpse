# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Prompt' do
  describe '#validate' do
    it 'must have a prompt' do
      expect { Prompt.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#report' do
    it 'marks prompt as reported' do
      prompt = Prompt.new(id: 2, prompt: 'This is a test')
      prompt.save!
      expect(prompt.reported).to eq(false)

      prompt.report!
      prompt = Prompt.find(prompt.id)
      expect(prompt.reported).to eq(true)
    end

    context 'with the first prompt' do
      it 'does nothing' do
        first_prompt = Prompt.find_or_create_by(id: 1, prompt: 'This is a test')
        expect(first_prompt.reported).to eq(false)

        first_prompt.report!
        first_prompt = Prompt.find(first_prompt.id)
        expect(first_prompt.reported).to eq(false)
      end
    end
  end
end
