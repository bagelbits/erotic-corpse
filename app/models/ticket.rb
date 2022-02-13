# frozen_string_literal: true

require 'securerandom'

class Ticket < ApplicationRecord
  self.table_name = 'tickets'

  STATUSES = {
    open: 'open',
    responded: 'responded',
    closed: 'closed',
  }.freeze

  CLOSURE_CODES = {
    skipped: 'skipped',
    submitted: 'submitted',
  }.freeze

  class << self
    def now_serving
      where(closure_code: nil).first
    end
  end

  validates :status, presence: true, inclusion: { in: STATUSES.values }

  before_create do
    self.token = SecureRandom.uuid
    self.checked_at = Time.zone.now
  end

  def check_in!
    self.checked_at = Time.zone.now
    save!
  end

  def skip!
    self.status = STATUSES[:closed]
    self.closure_code = CLOSURE_CODES[:skipped]
    save!
  end

  def got_response!
    self.status = STATUSES[:responded]
    save!
  end

  def close!
    self.status = STATUSES[:closed]
    self.closure_code = CLOSURE_CODES[:submitted]
    save!
  end

  def responded?
    status == STATUSES[:responded]
  end

  def closed?
    status == STATUSES[:closed]
  end

  def submitted?
    closure_code == CLOSURE_CODES[:submitted]
  end
end
