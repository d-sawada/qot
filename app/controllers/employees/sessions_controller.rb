# frozen_string_literal: true

class Employees::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params
  before_action :sys_admin_redirect

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    if signed_in?
      redirect_to '/top'
      return
    end
    emp = Employee.find_by(company_code: params[:company_code], no: params[:employee][:no])
    if emp.present?
      sign_in(:employee, emp)
      redirect_to timecard_path, notice: "ログインしました"
    else
      redirect_to employee_session_path, alert: "社員番号が違います"
    end
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in){|u| u.permit(:no, :remember_me)}
  end

  def after_sign_in_path_for(resource)
    timecard_path
  end

  def after_sign_out_path_for(resource)
    new_employee_session_path
  end

  def sys_admin_redirect
    redirect_to employees_path if sys_admin_signed_in?
  end
end
