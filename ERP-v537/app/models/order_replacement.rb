class OrderReplacement < ApplicationRecord
  belongs_to :order
  belongs_to :replacement_reference
end