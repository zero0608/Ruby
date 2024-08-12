class AddPaymentMethodToOrders < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :payment_method, :string
    add_column :orders, :store_credit, :string
  end
end
