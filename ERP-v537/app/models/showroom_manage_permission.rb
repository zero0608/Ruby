class ShowroomManagePermission < ApplicationRecord
  belongs_to :employee
  belongs_to :showroom
end