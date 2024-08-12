class AddCustomerIdToOrder < ActiveRecord::Migration[6.1]
  def change
    add_reference :orders, :customer, foreign_key: true, null: true
  end
end
