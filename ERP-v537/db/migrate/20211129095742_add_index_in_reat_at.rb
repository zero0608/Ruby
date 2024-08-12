class AddIndexInReatAt < ActiveRecord::Migration[6.1]
  def change
    add_index :notifications, :read_at
  end
end
