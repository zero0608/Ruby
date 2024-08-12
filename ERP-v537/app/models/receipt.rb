class Receipt < ApplicationRecord
  belongs_to :order_transaction
end
