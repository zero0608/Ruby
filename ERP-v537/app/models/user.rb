class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :timeoutable

  devise :two_factor_authenticatable, :otp_secret_encryption_key => Rails.application.secret_key_base
  devise :two_factor_backupable

  belongs_to :user_group
  belongs_to :supplier, optional: true
  belongs_to :warehouse, optional: true
  has_many :issues, dependent: :destroy
  has_many :notifications, as: :recipient, dependent: :destroy
  has_many :announcements, dependent: :destroy
  belongs_to :employee, optional: true
  has_many :received_tasks, class_name: "Task", foreign_key: "assignee_id"
  has_many :given_tasks, class_name: "Task", foreign_key: "owner_id" 
  has_associated_audits
  extend FriendlyId
  friendly_id :name, use: :slugged


  def name
   [
    [:first_name, :last_name],
   ]
  end

  def full_name
    if self.first_name.present? && self.last_name.present?
      self.first_name+' '+self.last_name
    else
      self.email
    end
  end

  # def superuser?
  #   user_group.permissions == "SUPERUSER"
  # end

  # def production?
  #   user_group.permissions == "PRODUCTION"
  # end

  # def nbapp?
  #   user_group.permissions == "NBAPP"
  # end

  def warehouse_admin?
    self.user_group.name == 'US DC Manager' || self.user_group.name == 'Canada DC Manager'
  end

  def warehouse_staff?
    self.user_group.name == 'US DC Staff' || self.user_group.name == 'Canada DC Staff'
  end

  def supplier?
    self.supplier.present?
  end

  def warehouse?
    self.warehouse.present?
  end

  def active_for_authentication?
    super && !self.deactivate
  end

end
