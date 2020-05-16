# frozen_string_literal: true

class Prompt < ActiveRecord::Base
  self.table_name = 'prompts'

  validates :prompt, presence: true

  def report!
    return if id == 1

    self.reported = true
    save!
  end
end
