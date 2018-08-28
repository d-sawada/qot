class CompaniesController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  before_action :authenticate_admins_company, except: [:top, :check_company, :create_company, :after_create_company]

  def top
    if admins_signed_in?
      redirect_to employees_path
    elsif employee_signed_in?
      redirect_to timecard_path
    else
      render layout: 'top_layout'
    end
  end
  def check_company
    if params[:code].present?
      company = Company.find_by_code(params[:code])
      if company.present?
        if params[:commit].present?
          if params[:commit] == "管理者様ログイン画面"
            redirect_to "/#{params[:code]}/admin/sign_in"
            return
          elsif params[:commit] == "社員ログイン画面"
            redirect_to "/#{params[:code]}/employee/sign_in"
            return
          else
            flash.now[:alert] = "不正な値です"
          end
        end
      else
        flash.now[:alert] = "存在しない企業コードです"
      end
    else
      flash.now[:alert] = "企業コードを入力してください"
    end
    render :top, layout: 'top_layout'
  end
  def create_company
    @company = Company.new(company_params)
    alpha = @company.name.downcase.split("").select{|c| 'a' <= c && c <= 'z' }
    companies = Company.all.pluck(:code)
    case alpha.length
    when 0
      prefix = "ja"
    when 1
      prefix = alpha[0] + "_"
    else
      prefix = alpha[0] + alpha[1]
    end
    i = 1
    while true do
      code = prefix + ("000" + i.to_s).slice(-4,4)
      break if companies.find{|com| com == code}.nil?
      i += 1
      p code
    end
    @company.code = code
    @company.save
    @admin = Admin.new({company_code: code, is_super: true, name: params[:admin][:name], email: params[:admin][:email], password: "password", password_confirmation: "password"})
    if @admin.save
      TrialMailer.start_trial_mail(@admin).deliver
      redirect_to after_create_company_path
    else
      @company.destroy
      render :top
    end
  end
  def after_create_company
    render layout: 'top_layout'
  end

  def setting
    # ========== パターン ==========
    @pattern_keys = %w(パターン名 出勤 退勤 休憩開始 休憩終了 編集 削除)
    work_patterns = @company.work_patterns
    @pattern_ids = work_patterns.pluck(:id).map{|id| "pattern-#{id}"}
    @pattern_rows = work_patterns.map{|pattern| pattern.to_table_row }

    # ========== テンプレート ==========
    pattern_names = Hash[work_patterns.map{|p| [p.id, p.name]}]
    @pattern_options = work_patterns.map{|p| [p.name, p.id] }
    templates = @company.work_templates
    @template_ids = templates.map{|template| "template-#{template.id}"}
    @template_keys = %w(テンプレート名 月 火 水 木 金 土 日 編集 削除)
    @template_rows = templates.map{|t| t.to_table_row(pattern_names) }

    # ========== 雇用区分 ==========
    template_names = Hash[templates.map{|t| [t.id, t.name]}]
    @template_options = templates.map{|t| [t.name, t.id]}
    statuses = @company.emp_statuses
    @status_ids = statuses.map{|status| "status-#{status.id}"}
    @status_keys = %w(雇用区分名 テンプレート名 編集 削除)
    @status_rows = statuses.map{|s| s.to_table_row(template_names) }

    # ========== 管理者 ==========
    admins = @company.admins
    @admin_ids = admins.map{|admin| "admin-#{admin.id}"}
    @admin_keys = %w(総合管理者 名前 メールアドレス 編集 削除)
    @admin_rows = admins.map{|admin| admin.to_table_row }

    # ========== メール設定 ==========
    @configs = Hash[@company.company_configs.map{|config| [config.key, config.value]}]

    # ========== build variable ==========
    if params[:pattern].present?
      @pattern = WorkPattern.find(params[:pattern].to_i)
      [:start, :end, :rest_start, :rest_end].each do |sym|
        @pattern[sym] = @pattern[sym].to_hm if @pattern[sym].present?
      end
      @pattern_submit = "パターン更新"
    else
      @pattern = @company.work_patterns.build
      @pattern_submit = "パターン作成"
    end
    if params[:template].present?
      @work_template = WorkTemplate.find(params[:template].to_i)
      @work_template_submit = "テンプレート更新"
    else
      @work_template = @company.work_templates.build
      @work_template_submit = "テンプレート作成"
    end
    if params[:status].present?
      @status = EmpStatus.find(params[:status].to_i)
      @status_submit = "雇用区分を更新"
    else
      @status = @company.emp_statuses.build
      @status_submit = "雇用区分を作成"
    end
    if params[:admin].present?
      @new_admin = Admin.find(params[:admin].to_i)
      @new_admin_submit = "管理者を更新"
    else
      @new_admin = @company.admins.build
      @new_admin_submit = "管理者を作成"
    end
  end

  def create_pattern
    @work_pattern = @company.work_patterns.build(work_pattern_params)
    if @work_pattern.save
      @row_id = "pattern-#{@work_pattern.id}"
      @row = @work_pattern.to_table_row
      @message = "パターンを作成しました"
      if @company.work_patterns.count <= 1
        redirect_to "/admin/setting#nav-label-pattern", notice: "パターンを作成しました"
      end
    end
  end
  def update_pattern
    @work_pattern = WorkPattern.find(params[:id])
    if @work_pattern.update(work_pattern_params)
      redirect_to "/admin/setting#nav-label-pattern", notice: "パターン[#{@work_pattern.name}]を更新しました"
    end
  end
  def destroy_pattern
    @work_pattern = WorkPattern.find(params[:id])
    if @work_pattern.destroy
      @message = "パターンを削除しました"
      if @company.work_patterns.count <= 1
        redirect_to "/admin/setting#nav-label-pattern", notice: "パターンを削除しました"
      end
    end
  end

  def create_template
    @work_template = @company.work_templates.build(work_template_params)
    if @work_template.save
      pattern_names = Hash[@company.work_patterns.map{|pattern| [pattern.id, pattern.name]}]
      @row_id = "template-#{@work_template.id}"
      @row = @work_template.to_table_row(pattern_names)
      @message = "テンプレートを作成しました"
      if @company.work_templates.count <= 1
        redirect_to "/admin/setting#nav-label-template", notice: "テンプレートを作成しました"
      end
    end
  end
  def update_template
    @work_template = WorkTemplate.find(params[:id])
    if @work_template.update(work_template_params)
      redirect_to "/admin/setting#nav-label-template", notice: "テンプレート[#{@work_template.name}]を更新しました"
    end
  end
  def destroy_template
    @work_template = WorkTemplate.find(params[:id])
    if @work_template.destroy
      @message = "テンプレートを削除しました"
      if @company.work_templates.count <= 1
        redirect_to "/admin/setting#nav-label-template", notice: "テンプレートを削除しました"
      end
    end
  end

  def create_status
    @status = @company.emp_statuses.build(emp_status_params)
    if @status.save
      template_names = Hash[@company.work_templates.map{|t| [t.id, t.name]}]
      @row_id = "status-#{@status.id}"
      @row = @status.to_table_row(template_names)
      @message = "雇用区分を作成しました"
    end
  end
  def update_status
    @status = EmpStatus.find(params[:id])
    if @status.update(emp_status_params)
      redirect_to "/admin/setting#nav-label-status", notice: "雇用区分[#{@status.name}]を更新しました"
    end
  end
  def destroy_status
    @status = EmpStatus.find(params[:id])
    if @status.destroy
      @message = "雇用区分を削除しました"
    end
  end

  def create_admin
    @new_admin = @company.admins.build(admin_params)
    if @new_admin.save
      @row_id = "admin-#{@new_admin.id}"
      @row = @new_admin.to_table_row
      @message = "管理者を作成しました"
    end
  end
  def update_admin
    @new_admin = Admin.find(params[:id])
    if @new_admin.update(admin_params)
      redirect_to "/admin/setting#nav-label-template", notice: "管理者[#{@new_admin.name}]を更新しました"
    end
  end
  def destroy_admin
    @new_admin = Admin.find(params[:id])
    if @new_admin.destroy
      @message = "管理者を削除しました"
    else
      @message = "管理者の削除に失敗しました"
    end
  end
  def update_company_config
    config = @company.company_configs.find_by_key(params[:company_config][:key])
    config.update(company_config_params)
  end

  private
  def company_params
    params.require(:company).permit(:name)
  end
  def work_pattern_params
    params.require(:work_pattern).permit(:company_id, :name, :start, :start_day, :end, :end_day, :rest_start, :rest_start_day, :rest_end, :rest_end_day)
  end
  def work_template_params
    params.require(:work_template).permit(:company_id, :name, :mon, :tue, :wed, :thu, :fri, :sat, :sun)
  end
  def emp_status_params
    params.require(:emp_status).permit(:company_id, :name, :work_template_id)
  end
  def company_config_params
    params.require(:company_config).permit(:key, :value)
  end
  def admin_params
    params.require(:admin).permit(:is_super, :name, :email, :password, :password_confirmation)
  end
end
