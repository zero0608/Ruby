class Task < ApplicationRecord
  belongs_to :owner, class_name: "User"

  has_many :comments, as: :commentable

  enum priority: [:low, :medium, :high]

  enum status: [:to_do, :in_progress, :completed]

  has_many_attached :files

  ALLOWED_CONTENT_TYPES = %w[image/png image/jpg image/jpeg application/pdf].freeze
  validates :files, content_type: { in: ALLOWED_CONTENT_TYPES, message: 'of attached files is not valid' },
  size: { less_than: 10.megabytes , message: 'Size should be less than 10MB' }

  audited

  Task.non_audited_columns = [ :id, :owner_id, :created_at, :updated_at ]
end