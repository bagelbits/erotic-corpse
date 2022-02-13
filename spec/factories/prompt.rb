# frozen_string_literal: true

FactoryBot.define do
  factory :prompt, class: 'Prompt' do
    sequence(:id)
    prompt { 'This is a test' }
  end
end
