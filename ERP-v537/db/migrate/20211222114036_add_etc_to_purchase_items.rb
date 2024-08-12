class AddEtcToPurchaseItems < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_items, :etc_date, :datetime
  end
end
