# frozen_string_literal: true

class Checklist < ApplicationRecord
  belongs_to :employee
  belongs_to :list_group, class_name: 'Checklist', optional: true
  has_many :group_members, class_name: 'Checklist', foreign_key: 'list_group_id', dependent: :destroy

  accepts_nested_attributes_for :group_members, allow_destroy: true
end
