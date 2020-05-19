# frozen_string_literal: true

class AddCheckedAtToTickets < ActiveRecord::Migration[6.0]
  def change
    add_column :tickets, :checked_at, :datetime
  end
end
