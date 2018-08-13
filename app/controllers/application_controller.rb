class ApplicationController < ActionController::Base
  before_action :set_company

  protected
  def set_company
    @company_code = nil
    @company = nil

    if employee_signed_in?
      @company_code = current_employee.company_code
      @company = current_employee.company
    end

    if admin_signed_in?
      @company_code = current_admin.company_code
      @company = current_admin.company
    end
    
  end
end
