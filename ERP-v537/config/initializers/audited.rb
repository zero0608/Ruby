Audited.current_user_method = :authenticated_user
Audited.config do |config|
  config.audit_class = Audit
end
