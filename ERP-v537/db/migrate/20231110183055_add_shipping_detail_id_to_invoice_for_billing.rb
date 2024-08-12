class AddShippingDetailIdToInvoiceForBilling < ActiveRecord::Migration[6.1]
  def change
    add_reference :invoice_for_billings, :shipping_detail, foreign_key: true
    add_reference :invoice_for_wgds, :shipping_detail, foreign_key: true
  end
end
