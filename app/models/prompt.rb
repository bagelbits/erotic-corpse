# frozen_string_literal: true

class Prompt < ActiveRecord::Base
  self.table_name = 'prompts'

  def self.last_prompt
    prompt = where(next_prompt: nil, reported: false).last

    # If there is no last prompt, get the last prompt that is not reported
    prompt ||= where(reported: false).last

    prompt
  end

  validates :prompt, presence: true

  def report!
    return if id == 1
    return if next_prompt

    self.reported = true
    save!
  end
end
