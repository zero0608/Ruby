class AddShippingDetailIdToAllShippings < ActiveRecord::Migration[6.1]
  def change
    add_reference :shipping_details, :approval_section, foreign_key: true, null: true
    add_reference :shipping_details, :review_section, foreign_key: true, null: true
    add_reference :shipping_details, :posting_section, foreign_key: true, null: true
    add_reference :shipping_details, :record_section, foreign_key: true, null: true
    add_column :shipping_details, :status_for_shipping, :integer
    add_reference :approval_sections, :shipping_detail, foreign_key: true, null: true
    add_reference :review_sections, :shipping_detail, foreign_key: true, null: true
    add_reference :posting_sections, :shipping_detail, foreign_key: true, null: true
    add_reference :record_sections, :shipping_detail, foreign_key: true, null: true
  end
end
