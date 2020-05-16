# frozen_string_literal: true

class Prompt < ActiveRecord::Base
  self.table_name = 'prompts'

  def self.last_prompt
    where(next_prompt: nil, reported: false).last
  end

  validates :prompt, presence: true

  def report!
    return if id == 1

    self.reported = true
    save!
  end
end
