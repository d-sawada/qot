class RequestsController < ApplicationController
  def index
    @requests = @company.requests if sys_admin_signed_in? || admiin_signed_in_?
    @requests = @employee.requests if employee_signed_in?

    @all_labels = %w(申請状況 登録者 修正対象者 対象日 出勤打刻 退勤打刻 修正後出勤打刻 修正後退勤打刻 詳細)
  end

  def show
    @request = Request.find(params[:id])

    @all_labels = %w(申請状況 登録者 修正対象者 対象日 出勤打刻 退勤打刻 修正後出勤打刻 修正後退勤打刻)
  end

  def new
    @request = Request.new(employee_id: params[:id], date: params[:date], state: "申請中")
  end

  def create
    @request = Request.new(request_params)
    @request.admin_id = @admin.id if @admin.present?
    b = @request.start.present? || @request.end.present?
    if @request.save && b
      redirect_to requests_path
    else
      errmes = b ? @request.errors.full_message : "修正打刻時間を入力して下さい"
      redirect_to new_request_url(id: @request.employee_id, date: @request.date), alert: errmes
    end
  end

  def update
    @request = Request.find(params[:id])
    if @request.state != "申請中" && params[:state].present? && @request.state != params[:state]
      redirect_to requests_path, alert: "不正なアクセスです"
    elsif @request.update(request_params)
      dayinfo = @request.employee.dayinfos.find_by_date(@request.date) || @request.employee.dayinfos.new(date: @request.date)
      dayinfo.update(start: @request.start, end: @request.end)
      redirect_to requests_path
    else
      render :show
    end
  end

  private
  def request_params
    params.require(:request).permit(:employee_id, :admin_id, :date, :state, :start, :end, :employee_comment, :admin_comment, {error: []})
  end
end
