class WhiteGloveDirectory < ApplicationRecord
  has_many :white_glove_addresses, dependent: :destroy
  has_many :shipping_details, dependent: :nullify
  has_many :returns, dependent: :nullify
end