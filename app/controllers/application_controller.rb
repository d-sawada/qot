class ApplicationController < ActionController::Base
  before_action :set_user_data

  def set_user_data
    if sys_admin_signed_in?
      @sys_admin = current_sys_admin
      @admin = Admin.first
      @employee = Employee.first
      @company_code = "ga0001"
      @company = Company.first
      @logout_url = destroy_sys_admin_session_path
      @user_info = "システム管理者" + @sys_admin.email
    elsif admin_signed_in?
      @admin = current_admin
      @company_code = @admin.company_code
      @company = @admin.company
      @logout_url = destroy_admin_session_url(company_code: @company_code)
      @user_info= "管理者" + @admin.email
    elsif employee_signed_in?
      @employee = current_employee
      @company_code = @employee.company_code
      @company = @employee.company
      @logout_url = destroy_employee_session_path(company_code: @company_code)
      @user_info = "従業員" + @employee.email
    end
  end
end
