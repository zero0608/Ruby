class Users::SessionsController < Devise::SessionsController
	def create
		signing_user = User.find_by(email: params[:user][:email])
    if signing_user.present? && signing_user.valid_password?(params[:user][:password]) && 
        signing_user.otp_required_for_login && params.dig(:user, :otp_attempt).blank?
      given_parameters = { email: params[:user][:email], password: params[:user][:password] }
      render "enter_otp", locals: { resource: signing_user, given_params: given_parameters }
    else
      super
    end
	end
end
