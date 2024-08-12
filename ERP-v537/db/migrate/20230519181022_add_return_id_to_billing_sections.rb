class AddReturnIdToBillingSections < ActiveRecord::Migration[6.1]
  def change
    add_reference :review_sections, :return, foreign_key: true
    change_column_null :review_sections, :order_id, true
    add_reference :approval_sections, :return, foreign_key: true
    change_column_null :approval_sections, :order_id, true
    add_reference :posting_sections, :return, foreign_key: true
    change_column_null :posting_sections, :order_id, true
    add_reference :record_sections, :return, foreign_key: true
    change_column_null :record_sections, :order_id, true
    add_reference :invoice_for_billings, :return, foreign_key: true
    change_column_null :invoice_for_billings, :order_id, true
    add_reference :invoice_for_wgds, :return, foreign_key: true
    change_column_null :invoice_for_wgds, :order_id, true
  end
end
