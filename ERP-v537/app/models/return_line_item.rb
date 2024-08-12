class ReturnLineItem < ApplicationRecord
  belongs_to :return
  belongs_to :line_item

  enum status: { pending: 0, disposed: 1, return_to_stock: 2, overstock: 3, marketplace: 4 }
  
  audited associated_with: :return

  ReturnLineItem.non_audited_columns = %i[quantity package_condition product_condition new_packaging market_value notes return_id line_item_id created_at updated_at]
end