class ProductPart < ApplicationRecord
  has_many :replacements
end