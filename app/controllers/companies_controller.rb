class CompaniesController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  before_action :authenticate_admins_company, only: [:setting]

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
    @pattern_keys = %w(パターン名 出勤 退勤 削除)
    work_patterns = @company.work_patterns
    @pattern_ids = work_patterns.pluck(:id).map{|id| "pattern-#{id}"}
    @pattern_rows = work_patterns.map{|p| [
      p.name,
      p.start_day + " " + p.start.to_hm,
      p.end_day + " " + p.end.to_hm,
      content_tag(:a, "削除", href: destroy_pattern_path(p), rel: "nofolloe", data: { remote: true, method: :delete,
          title: "パターン[#{p.name}]を削除しますか？", confirm: "削除しても[#{p.name}]が適用されたスケジュールは変更されません", cancel: "やめる", commit: "削除する"})
    ]}
    @pattern = @company.work_patterns.build
    # ========== <-パターン ==================================================
  end
  def create_pattern
    @work_pattern = @company.work_patterns.build(work_pattern_params)
    if @work_pattern.save
      @row_id = "pattern-#{@work_pattern.id}"
      @row = [
        @work_pattern.name,
        @work_pattern.start_day + " " + @work_pattern.start.to_hm,
        @work_pattern.end_day + " " + @work_pattern.end.to_hm,
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

  private
  def work_pattern_params
    params.require(:work_pattern).permit(:company_id, :name, :start, :start_day, :end, :end_day)
  end
end
