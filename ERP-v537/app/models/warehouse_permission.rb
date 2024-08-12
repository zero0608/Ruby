class WarehousePermission < ApplicationRecord
  belongs_to :user_group
  belongs_to :warehouse
end