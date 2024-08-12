class Factory < ApplicationRecord
  has_many :products, dependent: :nullify
  has_many :issues, dependent: :nullify
end