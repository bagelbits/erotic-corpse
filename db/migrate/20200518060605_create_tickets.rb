# frozen_string_literal: true

class CreateTickets < ActiveRecord::Migration[6.0]
  def change
    create_table :tickets do |t|
      t.string :status, null: false
      t.string :closure_code
      t.string :token, null: false

      t.timestamps
    end
  end
end
