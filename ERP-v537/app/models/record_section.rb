class RecordSection < ApplicationRecord
  belongs_to :shipping_detail, optional: true
  belongs_to :order, optional: true
  belongs_to :return, optional: true
  belongs_to :consolidation, optional: true

  enum status: { paid: 0, dispute: 1 }
end
