# frozen_string_literal: true

class Employees::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  # def create
  #   params[:employee][:email] = Company.find_by_code(params[:employee][:company_code]).employees.find_by_no(params[:employee][:no]).email
  #   p params
  #   self.resource = warden.authenticate!(auth_options)
  #   set_flash_message!(:notice, :signed_in)
  #   sign_in(resource_name, resource)
  #   yield resource if block_given?
  #   respond_with resource, location: after_sign_in_path_for(resource)
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in){|u| u.permit(:company_code, :no, :email, :password, :password_confirmation, :remember_me)}
  end

  def after_sign_in_path_for(resource)
    timecard_path
  end

  def after_sign_out_path_for(resource)
    new_employee_session_path
  end
end
