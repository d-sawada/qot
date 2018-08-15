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
      @admin = Admin.first
      @employee = Employee.first
    else
      @admin = current_admin
      @employee = current_employee
    end
  end
end
