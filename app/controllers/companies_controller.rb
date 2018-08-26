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
    # ================================================== パターン-> ==========
    @pattern_keys = %w(パターン名 出勤 退勤 休憩開始 休憩終了 削除)
    work_patterns = @company.work_patterns
    @pattern_ids = work_patterns.pluck(:id).map{|id| "pattern-#{id}"}
    @pattern_rows = work_patterns.map{|p| [
      p.name,
      p.start_day + " " + p.start.to_hm,
      p.end_day + " " + p.end.to_hm,
      p.rest_start_day.present? ? p.rest_start_day + " " + p.rest_start.to_hm : "",
      p.rest_end_day.present? ? p.rest_end_day + " " + p.rest_end.to_hm : "",
      content_tag(:a, "削除", href: p.id.nil? ? nil : destroy_pattern_path(p), rel: "nofollow", data: { remote: true, method: :delete,
          title: "パターン[#{p.name}]を削除しますか？", confirm: "削除しても[#{p.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
    ]}
    # ========== <-パターン ============================== テンプレート-> ==========
    pattern_names = Hash[work_patterns.map{|p| [p.id, p.name]}]
    @pattern_options = work_patterns.map{|p| [p.name, p.id] }
    templates = @company.work_templates
    @template_ids = templates.map{|template| "template-#{template.id}"}
    @template_keys = %w(テンプレート名 月 火 水 木 金 土 日 削除)
    @template_rows = templates.map{|t| t.to_table_row(pattern_names) }
    # ========== <-テンプレート ==============================  ==========

    # ========== 管理者 ==========
    admins = @company.admins
    @admin_ids = admins.map{|admin| "admin-#{admin.id}"}
    @admin_keys = %w(総合管理者 名前 メールアドレス)
    @admin_rows = admins.map{|admin| [(admin.is_super ? "〇" : ""), admin.name, admin.email] }
    # ========== メール設定 ==========
    @configs = Hash[@company.company_configs.map{|config| [config.key, config.value]}]
    # ========== build variable ==========
    @pattern = @company.work_patterns.build
    @work_template = @company.work_templates.build
    @admin = @company.admins.build
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
      @id = @work_template.id
    else
      @message = "テンプレートの削除に失敗しました"
    end
  end
  def create_admin
    @admin = @company.admins.build(admin_params)
    if @admin.save
      @message = "管理者を作成しました"
    else
      @message = "管理者の作成に失敗しました。入力を確認してください"
    end
  end
  def destroy_admin
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
  def company_config_params
    params.require(:company_config).permit(:key, :value)
  end
  def admin_params
    params.require(:admin).permit(:company_code, :name, :email, :password, :password_confirmation, :is_super)
  end
end
