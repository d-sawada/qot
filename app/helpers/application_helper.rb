module ApplicationHelper
  include ApplicationConstant
  include ActionView::Helpers::TagHelper

  def signed_in?
    sys_admin_signed_in? || admin_signed_in? || employee_signed_in?
  end

  def admins_signed_in?
    sys_admin_signed_in? || admin_signed_in?
  end

  def employees_signed_in?
    sys_admin_signed_in? || employee_signed_in?
  end

  def super_admin?
    sys_admin_signed_in? || (current_admin && current_admin.is_super)
  end

  def company_select(kind)
    code = params[:company_code]
    if code && Company.find_by_code(code)
      redirect_to "/#{code}/#{kind}/signed_in", alert: "ログインが必要です"
    else
      redirect_to top_url, alert: "会社コードを入力してください"
    end
  end

  def authenticate_admins_company
    company_select("admin") unless admins_signed_in?
  end

  def authenticate_employees_company
    company_select("employee") unless employees_signed_in?
  end

  def authenticate_company
    redirect_to top_url, alert: "会社コードを入力してください" unless signed_in?
  end

  def employee_daily_index_keys(ex_keys = [])
    %w(社員No 雇用形態) + ex_keys + %w(名前)
  end

  def employee_monthly_index_keys(ex_keys = [])
    %w(社員No 雇用形態) + ex_keys + %w(名前)
  end

  def checkbox(resource, id)
    content_tag(:div,
      content_tag(:input,
        nil,
        class: "form-check-input position-static",
        type: "checkbox",
        value: id,
        name: "#{resource.to_s}[][id]"
      ),
      class: "form-check"
    )
  end
end
