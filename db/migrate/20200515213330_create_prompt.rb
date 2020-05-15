# frozen_string_literal: true

class CreatePrompt < ActiveRecord::Migration[6.0]
  def change
    create_table :prompts do |t|
      t.string :prompt, null: false
      t.integer :next_prompt, null: true
      t.boolean :reported, default: false
      t.timestamps
    end
  end
end
