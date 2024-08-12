class AddClearAtToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_column :notifications, :clear_at, :datetime
  end
end
