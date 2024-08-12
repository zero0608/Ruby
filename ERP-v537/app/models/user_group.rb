class UserGroup < ApplicationRecord

  PERMISSIONS = ['NBAPP', 'PRODUCTION', 'SUPERUSER']
  has_many :users

  has_many :warehouse_permissions, dependent: :destroy

  accepts_nested_attributes_for :warehouse_permissions

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :update_group

  extend FriendlyId
  friendly_id :name, :use => :slugged

  private


  def update_group
    default_group = UserGroup.where(name: 'Default').first
    self.users.update_all(user_group_id: default_group.id)
  end
end
