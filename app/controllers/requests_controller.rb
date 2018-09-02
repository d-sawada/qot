class RequestsController < ApplicationController
  include ApplicationHelper
  

  before_action :authenticate_company, only: [:index, :show, :new, :create]
  before_action :authenticate_admins_company, only: [:update]

  def index
    requests = @company.requests if admins_signed_in?
    requests = @employee.requests if employee_signed_in?
    emp_names = Hash[@company.employees.map{ |emp| [emp.id, emp.name] }]
    admin_names = Hash[@company.admins.map{ |admin| [admin.id, admin.name] }]
    @table_keys = %w(申請状況 登録者 修正対象者 対象日 修正前出勤打刻 修正前退勤打刻) +
                  %w(修正後出勤打刻 修正後退勤打刻 詳細)
    @table_rows = requests.map{ |r| r.to_table_row(emp_names, admin_names) }
  end

  def show
    @request = Request.find(params[:id])

    @table_keys = %w(申請状況 登録者 修正対象者 対象日 出勤打刻 退勤打刻) +
                  %w(修正後出勤打刻 修正後退勤打刻)
    @table_rows = [@request.to_table_row]
  end

  def new
    @request = Request.new(employee_id: params[:id], state: "申請中")
    @date = params[:day]
    if @date.present?
      @request.date = @date
      dayinfo = Employee.find(params[:id]).dayinfos.find_by_date(@date)
      if dayinfo.present?
        @request.prev_start = dayinfo.start
        @request.prev_end = dayinfo.end
      end
    end
    employee = @request.employee
    @employee_info = employee.no + " " + employee.emp_status.name + " " +
                     employee.name
  end

  def create
    @request = Request.new(request_params)
    @request.admin_id = @admin.id if @admin.present?
    if @request.save
      redirect_to requests_path, notice: "申請しました"
    else
      employee = @request.employee
      @employee_info = employee.no + " " + employee.emp_status.name + " " +
                       employee.name
      render :new
    end
  end

  def update
    @request = Request.find(params[:id])
    if @request.state != "申請中" && params[:state] &&
       !params[:state].in("承認済", "棄却") && @request.state != params[:state]
      redirect_to requests_path, alert: "不正なアクセスです"
    elsif @request.update(request_params)
      emp_email = @request.employee.email
      value = @company.company_configs
                .find_by_key('send_mail_request_processed').value
      send_email = value == "送信する"
      if @request.state == "承認済"
        dayinfo = @request.employee.dayinfos.find_by_date(@request.date) ||
                  @request.employee.dayinfos.new(date: @request.date)
        dayinfo.update(start: @request.start, end: @request.end)
        RequestMailer.request_accepted_mail(emp_email ,@request.admin_comment)
          .deliver if send_email
      else
        RequestMailer.request_rejected_mail(emp_email ,@request.admin_comment)
          .deliver if send_email
      end
      message = "申請を#{@request.state == "承認済" ? "承認" : "棄却"}しました"
      redirect_to @request, notice: message
    else
      render :show
    end
  end

  private
  def request_params
    params.require(:request)
      .permit(:employee_id, :admin_id, :date, :state, :prev_start, :prev_end,
              :start, :end, :employee_comment, :admin_comment, {error: []})
  end
end
