class EmployeesController < ApplicationController
  include ApplicationHelper
  include DayinfosHelper
  include EmployeesHelper
  include ActionView::Helpers::TagHelper
  before_action :authenticate_admins_company, only: [:index, :new, :edit, :create, :update, :destroy]
  before_action :authenticate_company, only: [:show]
  before_action :set_employee, only: [:edit, :update, :destroy]

  def index
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    @date = Date.parse(@tday)
    employees = @company.employees.preload(:emp_status, :work_template).order(:no)
    work_patterns = Hash[@company.work_patterns.map{|pattern| [pattern.id, pattern]}]

    if @list == "day"
      dayinfos = Hash[@company.dayinfos.where(dayinfos: {date: @date}).map{|d| [d.employee_id, d]}]
      table_csv_keys, table_opt_keys= employee_daily_keys + pattern_daily_keys + dayinfo_daily_keys, ["詳細"]
      table_csv_rows, table_opt_rows = [], []
      employees.each do |emp|
        dayinfo = dayinfos[emp.id] || Dayinfo.new
        table_csv_rows << emp.data_array + work_patterns[emp.work_template.pattern_id_of(@date)].to_daily_data + dayinfo.daily_data
        table_opt_rows << [content_tag(:a, "詳細", href: "/admin/employees/#{emp.id}?day=#{@tday}&list=day")]
      end
    elsif @list == "month"
      dayinfos = Hash[@company.dayinfos.where("dayinfos.date between ? and ?", @date.beginning_of_month, @date.end_of_month)
          .select(<<-SELECT).group(:employee_id).map{|d| [d.employee_id, d]}]
            employee_id,
            sum(pre_workdays)      as sum_pre_workdays,
            sum(pre_worktimes)     as sum_pre_worktimes,
            sum(workdays)          as sum_workdays,
            sum(worktimes)         as sum_worktimes,
            sum(holiday_workdays)  as sum_holiday_workdays,
            sum(holiday_worktimes) as sum_holiday_worktimes
          SELECT
      table_csv_keys, table_opt_keys = employee_monthly_keys + dayinfo_monthly_keys, ["詳細"]
      table_csv_rows, table_opt_rows = [], []
      employees.each do |emp|
        dayinfo = dayinfos[emp.id] || Dayinfo.new
        table_csv_rows << emp.data_array + dayinfo.monthly_data
        table_opt_rows << [content_tag(:a, "詳細", href: employee_path(id: emp.id, day: @tday, list: "month"))]
      end
    elsif @list == "schedule"

    end

    @table_keys = table_csv_keys + table_opt_keys
    @table_rows = table_csv_rows.zip(table_opt_rows).map{|x,y| x + y}

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate do |csv|
          csv << table_csv_keys
          table_csv_rows.each{|row| csv << row }
        end
        filename = "Qot" + @date.strftime(@list == "day" ? "%Y-%m-%-d" : "%Y-%m") + ".csv"
        send_data(csv_data, filename: filename)
      end
      format.html
    end
  end

  def show
    @employee = Employee.find(params[:id]) if admins_signed_in?
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    @date = Date.parse(@tday)
    day_num = @date.end_of_month.day.to_i

    if @list == "day"
      dayinfo = @employee.dayinfos.where("date = ?", @tday).first || Dayinfo.new
      table_csv_keys, table_opt_keys = pattern_daily_keys + dayinfo_daily_keys, ["申請登録"]
      table_csv_rows = [(WorkPattern.find_by_id(@employee.work_template.pattern_id_of(@date)) || WorkPattern.new).to_daily_data + dayinfo.daily_data]
      table_opt_rows = [[content_tag(:a, "打刻修正を登録", href: new_request_url(id: @employee.id, day: @tday))]]
    elsif @list == "month"
      sum_dayinfo =  @employee.dayinfos.where("dayinfos.date between ? and ?", @date.beginning_of_month, @date.end_of_month)
          .select(<<-SELECT).group(:employee_id)[0]
            employee_id,
            sum(pre_workdays)      as sum_pre_workdays,
            sum(pre_worktimes)     as sum_pre_worktimes,
            sum(workdays)          as sum_workdays,
            sum(worktimes)         as sum_worktimes,
            sum(holiday_workdays)  as sum_holiday_workdays,
            sum(holiday_worktimes) as sum_holiday_worktimes
          SELECT
      sum_dayinfo ||= Dayinfo.new
      @sum_dayinfo_keys = dayinfo_monthly_keys
      @sum_dayinfo_rows = [sum_dayinfo.monthly_data]

      dayinfos = Hash[@employee.dayinfos.where("date between ? and ?", @tday.month_begin, @tday.month_end)
          .map{|d| [d.date.day, d] }]
      table_csv_keys, table_opt_keys = ["日付"] + pattern_daily_keys + dayinfo_daily_keys, %w(詳細 申請登録)
      table_csv_rows, table_opt_rows = [], []
      (1..day_num).each do |i|
        dayinfo = dayinfos[i] || Dayinfo.new
        table_csv_rows << [i] + (WorkPattern.find_by_id(@employee.work_template.pattern_id_of(@date.change(day: i))) || WorkPattern.new ).to_daily_data + dayinfo.daily_data
        table_opt_rows << [
          content_tag(:a, "詳細", href: employee_url(id: @employee.id, day: @date.change(day: i))),
          content_tag(:a, "打刻修正を登録", href: new_request_url(id: @employee.id, day: @date.change(day: i)))
        ]
      end
    elsif @list == "schedule"

    end

    @table_keys = table_csv_keys + table_opt_keys
    @table_rows = table_csv_rows.zip(table_opt_rows).map{|x,y| x + y}

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate do |csv|
          csv << table_csv_keys
          table_csv_rows.each{|row| csv << row }
        end
        filename = "Qot" + @date.strftime(@list == "day" ? "%Y-%m-%-d" : "%Y-%m") + "-#{@employee.name}" + ".csv"
        send_data(csv_data, filename: filename)
      end
      format.html
    end
  end

  def new
    @employee = @company.employees.new({password: "password", password_confirmation: "password"})
    @emp_statuses = @company.emp_statuses
  end

  def edit
    @emp_statuses = @company.emp_statuses
  end

  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to employees_path, notice: '社員を登録しました' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html {
          @emp_emp_status = @employee.emp_emp_status
          @emp_statuses = @company.emp_statuses
          render :new
        }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @employee.update(employee_params) &&
         @employee.emp_emp_status.update({employee_id: @employee.id, emp_status_id: params[:employee][:emp_emp_status_attributes][:emp_status_id]})
        format.html { redirect_to @employee, notice: "社員情報を更新しました" }
        format.json { render :show, status: :ok, location: @employee }
      else
        @emp_statuses = @company.emp_statuses
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path(list: params[:list]), notice: "社員を削除しました"
  end

  private
    def set_employee
      @employee = Employee.find(params[:id])
    end

    def employee_params
      params.require(:employee).permit(:company_code, :no, :name, :email, :password, :password_confirmation, emp_emp_status_attributes: [:company_id, :employee_id, :emp_status_id])
    end
end
