# frozen_string_literal: true

class ContainerOrder < ApplicationRecord
  belongs_to :order
  belongs_to :product_variant
  belongs_to :line_item
end
