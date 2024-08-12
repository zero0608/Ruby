class CreateNotifications < ActiveRecord::Migration[6.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: true, foreign_key: true
      t.references :order, null: true, foreign_key: true
      t.integer :status

      t.timestamps
    end
  end
end
