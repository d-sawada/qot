class CompaniesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_admins_company,
                except: [:top, :check_company, :create_company,
                         :after_create_company]

  def top
    case
    when admins_signed_in?
      redirect_to daily_index_path
    when employee_signed_in?
      redirect_to timecard_path
    else
      render layout: 'top_layout'
    end
  end

  def check_company
    commit = params[:commit]
    code = params[:code]
    error_message =
      case
      when !commit || !commit.in(["管理者様ログイン画面", "社員ログイン画面"])
        "不正な操作です"
      when !params[:code]
        "企業コードを入力して下さい"
      when !Company.find_by_code(params[:code])
        "存在しない企業コードです"
      else
        nil
      end
    
    if error_message
      flash.now[:alert] = error_message
      render :top, layout: 'top_layout'
    elsif commit == "管理者様ログイン画面"
      redirect_to "/#{code}}/admin/sign_in"
    else
      redirect_to "/#{code}/employee/sign_in"
    end
  end

  def create_company
    @company = Company.new(company_params)
    @company.code = make_company_code(@company.name)
    @company.save
    @admin = Admin.new(
      company_code: code,
      is_super: true,
      name: params[:admin][:name],
      email: params[:admin][:email],
      password: "password",
      password_confirmation: "password"
    )
    if @admin.save
      TrialMailer.start_trial_mail(@admin).deliver
      redirect_to after_create_company_path
    else
      @company.destroy
      flash.now[:alert] = "既に登録されているメールアドレスです"
      render :top
    end
  end

  def after_create_company
    render layout: 'top_layout'
  end

  def setting
    @tab_datas = %w(パターン テンプレート 雇用区分 社員追加情報 管理者 その他)
                   .zip(%w(pattern template status emp-ex admins others))
                   .map{ |title, render| {title: title, render: render} }

    patterns = @company.work_patterns
    templates = @company.work_templates
    statuses = @company.emp_statuses
    admins = @company.admins
    emp_exes = @company.emp_exes

    set_pattern_table(patterns)
    set_template_table(templates, patterns)
    set_status_table(statuses, templates)
    set_emp_ex_table(emp_exes)
    set_admin_table(admins)

    set_pattern(patterns)
    set_template(templates)
    set_status(statuses)
    set_emp_ex(emp_exes)
    set_admin(admins)

    # ========== メール設定 ==========
    @configs =
      Hash[@company.company_configs.pluck(:key, :value)]
  end

  def create_pattern
    @work_pattern = @company.work_patterns.build(work_pattern_params)
    if @work_pattern.save
      @row_id = "pattern-#{@work_pattern.id}"
      @row = @work_pattern.to_table_row
      @message = "パターンを作成しました"
      if @company.work_patterns.count <= 1
        redirect_to "/admin/setting#nav-label-pattern",
                    notice: "パターンを作成しました"
      end
    end
  end

  def update_pattern
    @work_pattern = WorkPattern.find(params[:id])
    if @work_pattern.update(work_pattern_params)
      redirect_to "/admin/setting#nav-label-pattern",
                  notice: "パターン[#{@work_pattern.name}]を更新しました"
    end
  end

  def destroy_pattern
    @work_pattern = WorkPattern.find(params[:id])
    if @work_pattern.destroy
      @message = "パターンを削除しました"
      if @company.work_patterns.count <= 1
        redirect_to "/admin/setting#nav-label-pattern",
                    notice: "パターンを削除しました"
      end
    end
  end

  def create_template
    @work_template = @company.work_templates.build(work_template_params)
    if @work_template.save
      pattern_names =
        Hash[@company.work_patterns.map{ |pattern| [pattern.id, pattern.name] }]
      @row_id = "template-#{@work_template.id}"
      @row = @work_template.to_table_row(pattern_names)
      @message = "テンプレートを作成しました"
      if @company.work_templates.count <= 1
        redirect_to "/admin/setting#nav-label-template",
                    notice: "テンプレートを作成しました"
      end
    end
  end

  def update_template
    @work_template = WorkTemplate.find(params[:id])
    if @work_template.update(work_template_params)
      redirect_to "/admin/setting#nav-label-template",
                  notice: "テンプレート[#{@work_template.name}]を更新しました"
    end
  end

  def destroy_template
    @work_template = WorkTemplate.find(params[:id])
    if @work_template.destroy
      @message = "テンプレートを削除しました"
      if @company.work_templates.count <= 1
        redirect_to "/admin/setting#nav-label-template",
                    notice: "テンプレートを削除しました"
      end
    end
  end

  def create_status
    @status = @company.emp_statuses.build(emp_status_params)
    if @status.save
      template_names = Hash[@company.work_templates.map{ |t| [t.id, t.name] }]
      @row_id = "status-#{@status.id}"
      @row = @status.to_table_row(template_names)
      @message = "雇用区分を作成しました"
    end
  end

  def update_status
    @status = EmpStatus.find(params[:id])
    if @status.update(emp_status_params)
      redirect_to "/admin/setting#nav-label-status",
                  notice: "雇用区分[#{@status.name}]を更新しました"
    end
  end

  def destroy_status
    @status = EmpStatus.find(params[:id])
    @status.emp_emp_statuses.each do |emp_emp_status|
      emp_emp_status.employee.destroy
    end
    if @status.destroy
      @message = "雇用区分を削除しました"
    end
  end

  def create_emp_ex
    @emp_ex = @company.emp_exes.build(emp_ex_params)
    if @emp_ex.save
      @row_id = "emp-ex-#{@emp_ex.id}"
      @row = @emp_ex.to_table_row
      @message = "社員追加情報を作成しました"
    end
  end

  def update_emp_ex
    @emp_ex = EmpEx.find(params[:id])
    prev_name = @emp_ex.name
    if @emp_ex.update(emp_ex_params)
      redirect_to "/admin/setting#nav-label-emp-ex",
                  notice: "社員追加情報名[#{prev_name}]を" \
                          "[#{@emp_ex.name}]に変更しました"
    end
  end

  def destroy_emp_ex
    @emp_ex = EmpEx.find(params[:id])
    if @emp_ex.destroy
      @message = "社員追加情報を削除しました"
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
    if @new_admin.update_with_password(admin_params)
      if @new_admin.id == @admin.id && admin_params[:password]
        redirect_to "/#{@company_code}/admin/sign_in",
                    notice: "もう一度ログインしてください"
      else
        redirect_to "/admin/setting#nav-label-admins",
                    notice: "管理者[#{@new_admin.name}]を更新しました"
      end
    end
  end

  def destroy_admin
    if @is_myself = (params[:id].to_i == @admin.id)
      @message = "ログイン中のアカウントを削除しようとしています"
    else
      @new_admin = Admin.find(params[:id])
      if @new_admin.destroy
        @message = "管理者を削除しました"
      else
        @message = "管理者の削除に失敗しました"
      end
    end
  end

  def update_company_config
    config = @company.company_configs.find_by_key(params[:company_config][:key])
    config.update(company_config_params)
  end

  private

  def set_pattern_table(patterns)
    @pattern_ids = patterns.pluck(:id).map{ |id| "pattern-#{id}" }
    @pattern_keys = %w(パターン名 出勤 退勤 休憩開始 休憩終了 編集 削除)
    @pattern_rows = patterns.map(&:to_table_row)
  end

  def set_pattern(patterns)
    if params[:pattern]
      @pattern = patterns.find(params[:pattern].to_i)
                   .select(%i(start end rest_start rest_end)).map(&:to_hm)
      @pattern_submit = "パターン更新"
    else
      @pattern = patterns.build
      @pattern_submit = "パターン作成"
    end
  end

  def set_template_table(templates, patterns)
    pattern_names = Hash[patterns.pluck(:id, :name)]
    @pattern_options = patterns.pluck(:name, :id)
    @template_ids = templates.pluck(:id).map{ |id| "pattern-#{id}" }
    @template_keys = %w(テンプレート名 月 火 水 木 金 土 日 編集 削除)
    @template_rows = templates.map{ |t| t.to_table_row(pattern_names) }
  end

  def set_template(templates)
    if params[:template]
      @template = templates.find(params[:template].to_i)
      @template_submit = "テンプレート更新"
    else
      @template = templates.build
      @template_submit = "テンプレート作成"
    end
  end

  def set_status_table(statuses, templates)
    template_names = Hash[templates.pluck(:id, :name)]
    @template_options = templates.pluck(:name, :id)
    @status_ids = statuses.pluck(:id).map{ |id| "status-#{id}" }
    @status_keys = %w(雇用区分名 テンプレート名 編集 削除)
    @status_rows = statuses.map{ |s| s.to_table_row(template_names) }
  end

  def set_status(statuses)
    if params[:status]
      @status = statuses.find(params[:status].to_i)
      @status_submit = "雇用区分を更新"
    else
      @status = statuses.build
      @status_submit = "雇用区分を作成"
    end
  end

  def set_emp_ex_table(emp_exes)
    @emp_ex_ids = emp_exes.pluck(:id).map{ |id| "emp-ex-#{id}" }
    @emp_ex_keys = %w(追加情報名 編集 削除)
    @emp_ex_rows = emp_exes.map(&:to_table_row)
  end

  def set_emp_ex(emp_exes)
    if params[:emp_ex]
      @emp_ex = emp_exes.find(params[:emp_ex].to_i)
      @emp_ex_submit = "社員追加情報を更新"
    else
      @emp_ex = emp_exes.build
      @emp_ex_submit = "社員追加情報を作成"
    end
  end

  def set_admin_table(admins)
    @admin_ids = admins.pluck(:id).map{ |id| "admin-#{id}" }
    @admin_keys = %w(総合管理者 名前 メールアドレス 編集 削除)
    @admin_rows = admins.map{ |admin| admin.to_table_row(@admin.id) }
  end

  def set_admin(admins)
    if params[:admin]
      @new_admin = admins.find(params[:admin].to_i)
      @new_admin_submit = "管理者を更新"
    else
      @new_admin = admins.build
      @new_admin_submit = "管理者を作成"
    end
  end

  def make_company_code(name)
    alpha = name.downcase.chars.select{|c| 'a' <= c && c <= 'z' }
    companiy_codes= Company.all.pluck(:code)
    case alpha.length
    when 0
      prefix = "ja"
    when 1
      prefix = alpha[0] + "_"
    else
      prefix = alpha[0] + alpha[1]
    end
    i = 1
    loop do
      code = prefix + ("000" + i.to_s).slice(-4,4)
      break unless companiy_codes.find{|company_code| comany_code == code}
      i += 1
    end
    code
  end

  def company_params
    params.require(:company).permit(:name)
  end

  def work_pattern_params
    params.require(:work_pattern)
      .permit(:company_id, :name, :start, :start_day, :end, :end_day,
              :rest_start, :rest_start_day, :rest_end, :rest_end_day)
  end

  def work_template_params
    params.require(:work_template)
      .permit(:company_id, :name, :mon, :tue, :wed, :thu, :fri, :sat, :sun)
  end

  def emp_status_params
    params.require(:emp_status)
      .permit(:company_id, :name, :work_template_id)
  end

  def emp_ex_params
    params.require(:emp_ex).permit(:company_id, :name)
  end

  def company_config_params
    params.require(:company_config).permit(:key, :value)
  end

  def admin_params
    params.require(:admin)
      .permit(:company_code, :is_super, :name, :email, :password,
              :password_confirmation)
  end
end
