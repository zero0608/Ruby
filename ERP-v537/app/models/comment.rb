# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :commentable, polymorphic: true

  audited allow_mass_assignment: true, associated_with: :commentable
  audited allow_mass_assignment: true, associated_with: :user
end
