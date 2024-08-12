class AddReferenceIdsToOrders < ActiveRecord::Migration[6.1]
  def change
    add_reference :orders, :approval_section, foreign_key: true, null: true
    add_reference :orders, :review_section, foreign_key: true, null: true
    add_reference :orders, :posting_section, foreign_key: true, null: true
    add_reference :orders, :record_section, foreign_key: true, null: true
    add_column :orders, :status_for_shipping, :integer

  end
end
