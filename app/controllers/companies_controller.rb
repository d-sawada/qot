class CompaniesController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  before_action :authenticate_admins_company, except: [:notice_company]

  def notice_company
  end
  def check_company
    if params[:code].present?
      company = Company.find_by_code(params[:code])
      if company.present?
        if params[:commit].present?
          if params[:commit] == "管理者様ログイン画面へ"
            redirect_to "/#{params[:code]}/admin/sign_in"
            return
          elsif params[:commit] == "社員ログイン画面へ"
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
    render :notice_company
  end

  def setting
    # ========== パターン ==========
    @pattern_keys = %w(パターン名 出勤 退勤 休憩開始 休憩終了 編集 削除)
    work_patterns = @company.work_patterns
    @pattern_ids = work_patterns.pluck(:id).map{|id| "pattern-#{id}"}
    @pattern_rows = work_patterns.map{|p| [
      p.name,
      p.start_day + " " + p.start.to_hm,
      p.end_day + " " + p.end.to_hm,
      p.rest_start_day.present? ? p.rest_start_day + " " + p.rest_start.to_hm : "",
      p.rest_end_day.present? ? p.rest_end_day + " " + p.rest_end.to_hm : "",
      content_tag(:a, "編集", href: p.id.nil? ? nil : "/admin/setting?pattern=#{p.id}#nav-label-pattern"),
      content_tag(:a, "削除", href: p.id.nil? ? nil : destroy_pattern_path(p), rel: "nofollow", data: { remote: true, method: :delete,
          title: "パターン[#{p.name}]を削除しますか？", confirm: "削除しても[#{p.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
    ]}

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
    @status_rows = statuses.map{|s| [
      s.name, template_names[s.work_template_id],
      content_tag(:a, "編集", href: s.id.nil? ? nil : "/admin/setting?status=#{s.id}#nav-label-status"),
      content_tag(:a, "削除", href: s.id.nil? ? nil : destroy_status_path(s), rel: "nofollow", data: { remote: true, method: :delete,
          title: "雇用区分[#{s.name}]を削除しますか？", confirm: "削除しても[#{s.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
    ]}

    # ========== 管理者 ==========
    admins = @company.admins
    @admin_ids = admins.map{|admin| "admin-#{admin.id}"}
    @admin_keys = %w(総合管理者 名前 メールアドレス 編集 削除)
    @admin_rows = admins.map{|admin| [
      (admin.is_super ? "〇" : ""), admin.name, admin.email,
      content_tag(:a, "編集", href: admin.id.nil? ? nil : "/admin/setting?admin=#{admin.id}#nav-label-admins"),
      content_tag(:a, "削除", href: (admin.id.nil? ? nil : destroy_admin_path(admin)), rel: "nofollow", data: { remote: true, method: :delete,
          title: "管理者[#{admin.name}]を削除しますか？", cancel: "やめる", commit: "削除する"})
    ]}

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
      @admin = Admin.find(params[:admin].to_i)
      @admin_submit = "管理者を更新"
    else
      @admin = @company.admins.build
      @admin_submit = "管理者を作成"
    end
  end

  def create_pattern
    @work_pattern = @company.work_patterns.build(work_pattern_params)
    if @work_pattern.save
      @row_id = "pattern-#{@work_pattern.id}"
      @row = [
        @work_pattern.name,
        @work_pattern.start_day + " " + @work_pattern.start.to_hm,
        @work_pattern.end_day + " " + @work_pattern.end.to_hm,
        (@work_pattern.rest_start_day.present? ? @work_pattern.rest_start_day + " " + @work_pattern.rest_start.to_hm : ""),
        (@work_pattern.rest_end_day.present? ? @work_pattern.rest_end_day + " " + @work_pattern.rest_end.to_hm : ""),
        content_tag(:a, "削除", href: destroy_pattern_path(@work_pattern), rel: "nofolloe", data: { remote: true, method: :delete,
            title: "パターン[#{@work_pattern.name}]を削除しますか？", confirm: "削除しても[#{@work_pattern.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
      ]
      @message = "パターンを作成しました"
    else
      @message = "パターンの作成に失敗しました。入力した値を確認してください"
    end
  end
  def destroy_pattern
    @work_pattern = WorkPattern.find(params[:id])
    if @work_pattern.destroy
      @message = "パターンを削除しました"
      @id = @work_pattern.id
    else
      @message = "パターンの削除に失敗しました"
    end
  end
  def create_template
    @work_template = @company.work_templates.build(work_template_params)
    if @work_template.save
      pattern_names = Hash[@company.work_patterns.map{|p| [p.id, p.name]}]
      @row_id = "template-#{@work_template.id}"
      @row = @work_template.to_table_row(pattern_names)
      @message = "テンプレートを作成しました"
    else
      @message = "テンプレートの作成に失敗しました。入力した値を確認してください"
    end
  end
  def destroy_template
    @work_template = WorkTemplate.find(params[:id])
    if @work_template.destroy
      @message = "テンプレートを削除しました"
    else
      @message = "テンプレートの削除に失敗しました"
    end
  end
  def create_status
    @status = @company.emp_statuses.build(emp_status_params)
    if @status.save
      template_names = Hash[@company.work_templates.map{|t| [t.id, t.name]}]
      @row_id = "status-#{@status.id}"
      @row = [
        @status.name, template_names[@status.work_template_id],
        content_tag(:a, "編集", href: @status.id.nil? ? nil : "/admin/setting?status=#{@status.id}#nav-label-status"),
        content_tag(:a, "削除", href: @status.id.nil? ? nil : destroy_status_path(@status), rel: "nofollow", data: { remote: true, method: :delete,
            title: "雇用区分[#{@status.name}]を削除しますか？", confirm: "削除しても[#{@status.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
      ]
      @message = "雇用区分を作成しました"
    else
      @message = "雇用区分の作成に失敗しました。入力した値を確認してください"
    end
  end
  def destroy_status
    @status = EmpStatus.find(params[:id])
    if @status.destroy
      @message = "雇用区分を削除しました"
    else
      @message = "雇用区分の削除に失敗しました"
    end
  end
  def create_admin
    @admin = @company.admins.build(admin_params)
    if @admin.save
      @row_id = "admin-#{@admin.id}"
      @row = [
        (@admin.is_super ? "〇" : ""), @admin.name, @admin.email,
        content_tag(:a, "削除", href: @admin.id.nil? ? nil : destroy_admin_path(@admin), rel: "nofollow", data: { remote: true, method: :delete,
            title: "管理者[#{@admin.name}]を削除しますか？",cancel: "やめる", commit: "削除する"})
      ]
      @message = "管理者を作成しました"
    else
      @message = "管理者の作成に失敗しました。入力を確認してください"
    end
  end
  def destroy_admin
    @admin = Admin.find(params[:id])
    if @admin.destroy
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
    params.require(:admin).permit(:company_code, :name, :email, :password, :password_confirmation, :is_super)
  end
end
