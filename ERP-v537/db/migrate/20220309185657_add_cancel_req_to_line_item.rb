class AddCancelReqToLineItem < ActiveRecord::Migration[6.1]
  def change
    add_column :line_items, :cancel_request_check, :integer
  end
end
