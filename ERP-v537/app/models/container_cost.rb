# frozen_string_literal: true

class ContainerCost < ApplicationRecord
  belongs_to :container, optional: true
end
