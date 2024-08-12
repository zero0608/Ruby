class Showroom < ApplicationRecord
  has_many :appointments, dependent: :nullify
  has_many :employees, dependent: :nullify
  has_many :showroom_manage_permissions, dependent: :destroy

  belongs_to :warehouse
end