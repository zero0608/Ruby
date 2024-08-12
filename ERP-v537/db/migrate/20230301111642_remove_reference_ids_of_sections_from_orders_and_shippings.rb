class RemoveReferenceIdsOfSectionsFromOrdersAndShippings < ActiveRecord::Migration[6.1]
  def change
    remove_reference :shipping_details, :approval_section, foreign_key: true, null: true
    remove_reference :shipping_details, :review_section, foreign_key: true, null: true
    remove_reference :shipping_details, :posting_section, foreign_key: true, null: true
    remove_reference :shipping_details, :record_section, foreign_key: true, null: true
    remove_reference :orders, :approval_section, foreign_key: true, null: true
    remove_reference :orders, :review_section, foreign_key: true, null: true
    remove_reference :orders, :posting_section, foreign_key: true, null: true
    remove_reference :orders, :record_section, foreign_key: true, null: true
  end
end
