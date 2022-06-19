# frozen_string_literal: true

class CreateDisbursements < ActiveRecord::Migration[7.0]
  def change
    create_table :disbursements do |t|
      t.integer :amount, default: 0
      t.references :order, null: false, foreign_key: true

      t.timestamps
    end
  end
end
