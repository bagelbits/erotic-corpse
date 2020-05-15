# frozen_string_literal: true

class Prompt < ActiveRecord::Base
  self.table_name = 'prompts'

  validates :prompt, presence: true

  def report!
    self.reported = true
    save!
  end
end
