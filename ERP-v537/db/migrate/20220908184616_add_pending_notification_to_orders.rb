class AddPendingNotificationToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :pending_payment_notification, :integer
  end
end
