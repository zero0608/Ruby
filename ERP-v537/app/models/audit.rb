# frozen_string_literal: true

class Audit < Audited::Audit
  before_save do
    if ::Audited.store[:audited_user].to_s.present?
      self.username = ::Audited.store[:audited_user]
    elsif ::Audited.store[:current_user].present?
      self.username = ::Audited.store[:current_user].first_name
      self.user_id = ::Audited.store[:current_user].id
      self.user_type = ::Audited.store[:current_user].class.name
    end
  end
end
