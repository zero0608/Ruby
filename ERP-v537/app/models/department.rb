class Department < ApplicationRecord
  has_many :employees
  has_many :positions, dependent: :destroy
  
  accepts_nested_attributes_for :positions, allow_destroy: true
end