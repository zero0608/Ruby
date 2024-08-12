class AddShippedDateToLineItems < ActiveRecord::Migration[6.1]
  def change
    add_column :shipping_details, :shipped_date, :datetime
  end
end
