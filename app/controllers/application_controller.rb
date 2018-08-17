class ApplicationController < ActionController::Base
  before_action :set_company
  before_action :set_user_data

  protected
  def set_company
    if employee_signed_in?
      @company_code = current_employee.company_code
      @company = current_employee.company
    end

    if admin_signed_in?
      @company_code = current_admin.company_code
      @company = current_admin.company
    end
  end

  def set_user_data
    if sys_admin_signed_in?
      @company_code = "ga0001"
      @company = Company.first
      @sys_admin = current_sys_admin
      @admin = Admin.first
      @employee = Employee.first
    else
      @admin = current_admin
      @employee = current_employee
    end
    if sys_admin_signed_in?
      @logout_url = destroy_sys_admin_session_url
      @user_info = "システム管理者" + @sys_admin.email
    elsif admin_signed_in?
      @logout_url = destroy_admin_session_url
      @user_info= "管理者" + @admin.email
      @logout_url = destroy_employee_session_url
      @user_info = "従業員" + @employee.email
    end
  end
end
