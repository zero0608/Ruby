class ReserveItem < ApplicationRecord
  belongs_to :line_item, optional: true
end