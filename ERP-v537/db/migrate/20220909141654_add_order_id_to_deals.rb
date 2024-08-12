class AddOrderIdToDeals < ActiveRecord::Migration[6.1]
  def change
    add_reference :deals, :order, foreign_key: true, null: true
  end
end
