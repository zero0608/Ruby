class AddFieldsToNotifications < ActiveRecord::Migration[6.1]
  def change
    add_reference :notifications, :recipient, polymorphic: true, null: false
    add_column :notifications, :type, :string
    add_column :notifications, :params, :json
    add_column :notifications, :read_at, :datetime
    remove_reference :notifications, :user, null: true, foreign_key: true
    remove_reference :notifications, :order, null: true, foreign_key: true
    remove_column :notifications, :status, :integer
  end
end