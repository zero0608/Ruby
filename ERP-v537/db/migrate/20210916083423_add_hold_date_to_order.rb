class AddHoldDateToOrder < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :hold_until_date, :datetime
  end
end
