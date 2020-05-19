# frozen_string_literal: true

FactoryBot.define do
  factory :ticket, class: Ticket do
    sequence(:id)
    token { SecureRandom.uuid }
  end
end
