# frozen_string_literal: true

class ContainerPurchase < ApplicationRecord
  belongs_to :container
  belongs_to :purchase_item
end
