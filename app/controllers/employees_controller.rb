class EmployeesController < ApplicationController
  include EmployeesHelper
  include ActionView::Helpers::TagHelper
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  def index
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    @date = Date.parse(@tday)
    employees = @company.employees.preload(:emp_status).order(:no)

    if @list == "day"
      day_syms = [:pre_start, :pre_end, :start, :end, :rest_start, :rest_end]
      dayinfos = Hash[@company.dayinfos.where(dayinfos: {date: @date}).map{|d| [d.employee_id, d]}]
      table_csv_keys = employee_daily_keys
      table_opt_keys= ["詳細"]
      table_csv_rows = []
      table_opt_rows = []
      employees.zip(0..employees.length - 1).map do |emp, i|
        dayinfo = dayinfos[emp.id] || Dayinfo.new
        table_csv_rows[i] = emp.data_array + day_syms.map{|sym| dayinfo[sym].to_hm}
        table_opt_rows[i] = [content_tag(:a, "詳細", href: "/admin/employees/#{emp.id}?day=#{@tday}&list=day")]
      end
    elsif @list == "month"
      day_syms = [:sum_pre_workdays, :sum_pre_worktimes, :sum_workdays, :sum_worktimes, :sum_holiday_workdays, :sum_holiday_worktimes]
      dayinfos = Hash[@company.dayinfos.where("dayinfos.date between ? and ?", @date.beginning_of_month, @date.end_of_month).select(<<-SELECT).group(:employee_id).map{|d| [d.employee_id, d]}]
        employee_id,
        sum(pre_workdays) as sum_pre_workdays,
        sum(pre_worktimes) as sum_pre_worktimes,
        sum(workdays) as sum_workdays,
        sum(worktimes) as sum_worktimes,
        sum(holiday_workdays) as sum_holiday_workdays,
        sum(holiday_worktimes) as sum_holiday_worktimes
      SELECT
      table_csv_keys = employee_monthly_keys
      table_opt_keys = ["詳細"]
      table_csv_rows = []
      table_opt_rows = []
      employees.zip(0..employees.length - 1).map do |emp, i|
        dayinfo = dayinfos[emp.id] || Hash[day_syms.zip(employee_monthly_keys.map{nil})]
        table_csv_rows[i] = emp.data_array + [
          dayinfo[:sum_pre_workdays],
          dayinfo[:sum_pre_worktimes].min_to_times,
          dayinfo[:sum_workdays],
          dayinfo[:sum_worktimes].min_to_times,
          dayinfo[:sum_holiday_workdays],
          dayinfo[:sum_holiday_worktimes].min_to_times
        ]
        table_opt_rows[i] = [content_tag(:a, "詳細", href: employee_path(id: emp.id, day: @tday, list: "month"))]
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
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    @date = Date.parse(@tday)
    day_num = @date.end_of_month.day.to_i
    day_syms = [:pre_start, :pre_end, :start, :end, :rest_start, :rest_end]
    day_keys = %w(所定出勤 所定退勤 出勤打刻 退勤打刻 休憩開始 休憩終了)

    if @list == "day"
      day = @employee.dayinfos.where("date = ?", @tday).first
      day_val = day.present? ? day_syms.map{|sym| day.try(sym).to_hm} : day_keys.map{nil}
      table_csv_keys = day_keys
      table_opt_keys = %w(申請登録)
      table_csv_rows = [day_val]
      table_opt_rows = [[content_tag(:a, "打刻修正を登録", href: new_request_url(id: @employee.id, date: @tday))]]
    elsif @list == "month"
      days = @employee.dayinfos.where("date between ? and ?", @tday.month_begin, @tday.month_end)
      day_vals = days.map{|day| [day.date.day, day_syms.map{|sym| day.try(sym).to_hm}]}
      table_csv_keys = ["日付"] + day_keys
      table_opt_keys = %w(詳細 申請登録)
      table_csv_rows = (1..day_num).map{|i| [i] + (1..table_csv_keys.length - 1).map{ "" } }
      day_vals.each{|val| (1..day_keys.length).each{|i| table_csv_rows[val[0]-1][i] = val[1][i-1]}}
      table_opt_rows = (1..day_num).map{|i| [
        content_tag(:a, "詳細", href: employee_url(id: @employee.id, date: @date.change(day: i))),
        content_tag(:a, "打刻修正を登録", href: new_request_url(id: @employee.id, date: @date.change(day: i)))
      ]}
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
    @emp_emp_status = @employee.emp_emp_status
    @emp_statuses = @company.emp_statuses
  end

  def edit
    @emp_statuses = @company.emp_statuses
    p @employee
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
        format.html { redirect_to edit_employee_path(@employee)}
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @employee.destroy
    redirect_to employees_path(list: params[:list])
  end

  private
    def set_employee
      @employee = Employee.find(params[:id])
    end

    def employee_params
      params.require(:employee).permit(:company_code, :no, :name, :email, emp_emp_status_attributes: [:employee_id, :id])
    end
end
