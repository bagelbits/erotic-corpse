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
      prompt = Prompt.new(prompt: 'This is a test')
      prompt.save!
      expect(prompt.reported).to eq(false)

      prompt.report!
      prompt = Prompt.find(prompt.id)
      expect(prompt.reported).to eq(true)
    end
  end
end
