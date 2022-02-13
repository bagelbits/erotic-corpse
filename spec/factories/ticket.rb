# frozen_string_literal: true

FactoryBot.define do
  factory :ticket, class: 'Ticket' do
    sequence(:id)
    status { Ticket::STATUSES[:open] }
    before(:create) do |ticket|
      ticket.token = SecureRandom.uuid
    end
  end
end
