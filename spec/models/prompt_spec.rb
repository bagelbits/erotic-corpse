# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Prompt' do
  describe ':last_prompt' do
    let(:first_prompt) { Prompt.create(prompt: 'This is a test') }
    let(:second_prompt) { Prompt.create(prompt: 'This is a test') }
    let(:third_prompt) { Prompt.create(prompt: 'This is a test') }

    it 'gives the last Prompt without a next_prompt' do
      first_prompt.next_prompt = second_prompt.id
      first_prompt.save!
      second_prompt.next_prompt = third_prompt.id
      second_prompt.save!
      expect(Prompt.last_prompt.id).to eq(third_prompt.id)
    end

    context 'if prompted is reported' do
      it 'is ignored' do
        first_prompt.next_prompt = second_prompt.id
        first_prompt.save!
        third_prompt.report!
        expect(Prompt.last_prompt.id).to eq(second_prompt.id)
      end
    end
  end

  describe '#validate' do
    it 'must have a prompt' do
      expect { Prompt.create! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe '#report' do
    it 'marks prompt as reported' do
      prompt = Prompt.create(id: 2, prompt: 'This is a test')
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
