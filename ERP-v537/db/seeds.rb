UserGroup.find_or_create_by(name: 'Default', permissions: 'NBAPP')

Supplier.find_or_create_by(name: 'Default')

user_group = UserGroup.find_by(name: 'Default')
if Rails.env == 'development'
  admin_user = User.find_by(email: 'admin@gmail.com')
  User.create(email: 'admin@gmail.com', user_group: user_group, password: 123456, password_confirmation: 123456, first_name: 'admin', last_name: 'user') unless admin_user.present?
else

  admin_user = User.find_by(email: 'admin@eternity-erp.com')
  User.create(email: 'admin@eternity-erp.com', user_group: user_group, password: 'Eternity!@', password_confirmation: 'Eternity!@', first_name: 'admin', last_name: 'user') unless admin_user.present?
end