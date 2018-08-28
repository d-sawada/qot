class ApplicationController < ActionController::Base
  before_action :set_user_data, :trial_fail

  def set_user_data
    if sys_admin_signed_in?
      @sys_admin = current_sys_admin
      @company_code = params[:company_code] || Company.first.code
      @company = Company.find_by_code(@company_code)
      @admin = @company.admins.first
      @employee = @company.employees.first
      @logout_url = destroy_sys_admin_session_path
      @user_kind = "システム管理者"
      @user_identifer = @sys_admin.email
    elsif admin_signed_in?
      @admin = current_admin
      @company_code = @admin.company_code
      @company = @admin.company
      @logout_url = destroy_admin_session_url(company_code: @company_code)
      @user_kind= "管理者 - " + @admin.name + "様"
      @user_identifer = @admin.email
    elsif employee_signed_in?
      @employee = current_employee
      @company_code = @employee.company_code
      @company = @employee.company
      @logout_url = destroy_employee_session_path(company_code: @company_code)
      @user_kind = "社員 - " + @employee.name
      @user_identifer = @employee.email
    end
  end
  def trial_fail
    kind = nil
    kind = "admin" if admin_signed_in?
    kind = "employee" if employee_signed_in?
    if kind.present?
      if (DateTime.now.to_i - @company.created_at.to_i) > 30 * 24 * 3600
        sign_out(@admin)
        redirect_to "/#{@company_code}/#{kind}/sign_in", alert: "トライアル期間が終了しました"
      end
    end
  end
end
