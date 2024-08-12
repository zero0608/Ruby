class AddStatusToPurchaseCancelreq < ActiveRecord::Migration[6.1]
  def change
    add_column :purchase_cancelreqs, :status, :integer
  end
end
