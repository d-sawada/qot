class EmployeesController < ApplicationController
  include ApplicationHelper
  include ActionView::Helpers::TagHelper
  before_action :authenticate_admins_company, only: [:daily_index, :monthly_index, :index, :new, :edit, :create, :update, :destroy]
  before_action :authenticate_company, only: [:show]
  before_action :set_employee, only: [:edit, :update, :destroy]
  before_action :set_data, only: [:daily_index, :monthly_index]

  def daily_index
    @pattern_by_id = Hash[@company.work_patterns.map{|pattern| [pattern.id, pattern]}]
    dayinfo_by_emp_id = Hash[@company.dayinfos.where(dayinfos: {date: @date}).map{|d| [d.employee_id, d]}]
    csv_keys = employee_daily_index_keys(@emp_exes.pluck(:name)) + pattern_daily_index_keys + dayinfo_daily_index_keys
    @table_keys = %w(✔︎) + csv_keys + %w(詳細)
    csv_rows, @table_rows = [], []
    @employees.each do |emp|
      dayinfo = dayinfo_by_emp_id[emp.id] || Dayinfo.new
      pattern = @pattern_by_id[dayinfo.work_pattern_id || emp.work_template.pattern_id_of(@date)] || WorkPattern.new
      id_to_ex_vals = Hash[emp.ex_vals.map{|val| [val.emp_ex_id, val.value]}]
      csv_row = emp.daily_index_row(@emp_exes.map{|ex| id_to_ex_vals[ex.id] || ""}) + pattern.daily_index_row + dayinfo.daily_index_row
      csv_rows << csv_row
      @table_rows << [checkbox(:employee, emp.id)] + csv_row + [content_tag(:a, "詳細", href: employee_path(id: emp.id, day: @tday, list: "day"))]
    end
    respond_to do |format|
      format.csv do
        csv_data = CSV.generate do |csv|
          csv << csv_keys
          csv_rows.each{|row| csv << row }
        end
        send_data(csv_data, filename: @date.strftime("Qot%Y-%m-%-d.csv"))
      end
      format.html
    end
  end
  def monthly_index
    dayinfo_by_emp_id = Hash[@company.dayinfos.monthly(@date).map{|d| [d.employee_id, d]}]
    csv_keys = employee_monthly_index_keys(@emp_exes.pluck(:name)) + dayinfo_monthly_keys
    @table_keys = %w(✔︎) + csv_keys + %w(詳細)
    csv_rows, @table_rows = [], []
    @employees.each do |emp|
      dayinfo = dayinfo_by_emp_id[emp.id] || Dayinfo.new
      id_to_ex_vals = Hash[emp.ex_vals.map{|val| [val.emp_ex_id, val.value]}]
      csv_row = emp.monthly_index_row(@emp_exes.map{|ex| id_to_ex_vals[ex.id] || ""}) + dayinfo.monthly_index_row
      csv_rows << csv_row
      @table_rows << [checkbox(:employee, emp.id)] + csv_row + [content_tag(:a, "詳細", href: employee_path(id: emp.id, day: @tday, list: "month"))]
    end
    respond_to do |format|
      format.csv do
        csv_data = CSV.generate do |csv|
          csv << csv_keys
          csv_rows.each{|row| csv << row }
        end
        send_data(csv_data, filename: @date.strftime("Qot%Y-%m.csv"))
      end
      format.html
    end
  end

  def index
    @list = params[:list] || "day"
    @tday = params[:day] || (@date = Date.current).to_s
    @date ||= Date.parse(@tday)
    employees = @company.employees.preload(:emp_status, :work_template).order(:no)
    @work_pattern_names = @company.work_patterns
    work_patterns = Hash[@work_pattern_names.map{|pattern| [pattern.id, pattern]}]
    @work_pattern_names = @work_pattern_names.map{|pattern| [pattern.id, pattern.name]}

    if @list == "day"
      dayinfos = Hash[@company.dayinfos.where(dayinfos: {date: @date}).map{|d| [d.employee_id, d]}]

      table_csv_keys, table_opt_keys= employee_daily_keys + pattern_daily_keys + dayinfo_daily_keys, ["詳細"]
      table_csv_rows, table_opt_rows = [], []
      employees.each do |emp|
        dayinfo = dayinfos[emp.id] || Dayinfo.new
        pattern_id = dayinfo.work_pattern_id || emp.work_template.pattern_id_of(@date)
        pattern = work_patterns[pattern_id] || WorkPattern.new
        table_csv_rows << emp.data_array + pattern.to_daily_data + dayinfo.daily_data
        table_opt_rows << [content_tag(:a, "詳細", href: "/admin/employees/#{emp.id}?day=#{@tday}&list=day")]
      end
    elsif @list == "month"
      dayinfos = Hash[@company.dayinfos.monthly(@date).map{|d| [d.employee_id, d]}]
      table_csv_keys, table_opt_keys = employee_monthly_keys + dayinfo_monthly_keys, ["詳細"]
      table_csv_rows, table_opt_rows = [], []
      employees.each do |emp|
        dayinfo = dayinfos[emp.id] || Dayinfo.new
        table_csv_rows << emp.data_array + dayinfo.monthly_data
        table_opt_rows << [content_tag(:a, "詳細", href: employee_path(id: emp.id, day: @tday, list: "month"))]
      end
    end

    checkboxis = employees.map do |emp|
      [content_tag(:div, content_tag(:input, nil, class: "form-check-input position-static", type: "checkbox", value: emp.id, name: "employee[][id]"), class: "form-check")]
    end
    @table_keys = ["✔︎"] + table_csv_keys + table_opt_keys
    @table_rows = checkboxis.zip(table_csv_rows, table_opt_rows).map{|x,y,z| x + y + z}

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
      sum_dayinfo =  @employee.dayinfos.monthly(@date)[0]
      sum_dayinfo ||= Dayinfo.new
      @sum_dayinfo_keys = dayinfo_monthly_keys
      @sum_dayinfo_rows = [sum_dayinfo.monthly_data]

      dayinfos = Hash[@employee.dayinfos.where("date between ? and ?", @tday.month_begin, @tday.month_end).map{|d| [d.date.day, d] }]
      work_patterns = Hash[@company.work_patterns.map{|pattern| [pattern.id, pattern]}]
      table_csv_keys, table_opt_keys = ["日付"] + pattern_daily_keys + dayinfo_daily_keys, %w(詳細 申請登録)
      table_csv_rows, table_opt_rows = [], []
      (1..day_num).each do |i|
        dayinfo = dayinfos[i] || Dayinfo.new
        pattern_id = dayinfo.work_pattern_id || @employee.work_template.pattern_id_of(@date.change(day: i))
        pattern = work_patterns[pattern_id] || WorkPattern.new
        table_csv_rows << [i] + pattern.to_daily_data + dayinfo.daily_data
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
    @emp_exes = @company.emp_exes
    @ex_vals = {}
  end

  def edit
    @emp_statuses = @company.emp_statuses
    @emp_exes = @company.emp_exes
    @ex_vals = Hash[@employee.ex_vals.map{|val| [val.emp_ex_id, val.value]}]
  end

  def create
    @employee = Employee.new(employee_params)
    @company.emp_exes.each do |emp_ex|
      @employee.ex_vals.build({emp_ex_id: emp_ex.id, value: params[:emp_ex][emp_ex.name]})
    end

    respond_to do |format|
      if @employee.save
        format.html { redirect_to daily_index_path, notice: '社員を登録しました' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html {
          @emp_statuses = @company.emp_statuses
          @emp_exes = @company.emp_exes
          @ex_vals = Hash[@company.emp_exes.map{|ex| [ex.id, params[:emp_ex][ex.name]]}]
          render :new
        }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @company.emp_exes.each do |emp_ex|
      @employee.ex_vals.build({emp_ex_id: emp_ex.id, value: params[:emp_ex][emp_ex.name]})
    end
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: "社員情報を更新しました" }
        format.json { render :show, status: :ok, location: @employee }
      else
        @emp_statuses = @company.emp_statuses
        @emp_exes = @company.emp_exes
        @ex_vals = Hash[@company.emp_exes.map{|ex| [ex.id, params[:emp_ex][ex.name]]}]
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def bulk_action
    if params[:employee].present?
      @ids = params[:employee].pluck(:id)
      if params[:bulk_action] == "bulk_change_pattern"
        employees = Employee.where("id in (#{@ids.join(", ")})").preload(:dayinfos)
        employees.each do |emp|
          dayinfo = emp.dayinfos.where("date = ?", params[:day])
          dayinfo.update({work_pattern_id: params[:pattern_id]}) if dayinfo.present?
        end
      elsif params[:bulk_action] == "bulk_request"
        @date = Date.parse(params[:day]) || Date.current
        return render :bulk_create_requests
      end
    end
    redirect_to daily_index_path(day: params[:day])
  end

  def bulk_create_requests
    @ids = params[:ids].map{|id| id.to_i}
    return if @ids.blank?
    @date = params[:date]
    @start = params[:start]
    @end = params[:end]
    @admin_comment = params[:admin_comment]
    emp_id_to_dayinfo = Hash[Dayinfo.left_joins(:employee).where("dayinfos.date = ? and employees.id in (#{@ids.join(', ')})", @date).select("dayinfos.id, dayinfos.employee_id, dayinfos.start, dayinfos.end")
      .map{|result| [result.employee_id, {id: result.id, start: result.start, end: result.end}]}]

    @ids.each do |id|
      Request.create({employee_id: id, admin_id: @admin.id, state: "承認済", date: @date, start: @start, end: @end, admin_comment: @admin_comment, prev_start: emp_id_to_dayinfo[id][:start], prev_end: emp_id_to_dayinfo[id][:end]})
      dayinfo = Dayinfo.find_by_id(emp_id_to_dayinfo[id][:id])
      if dayinfo.present?
        dayinfo.update({start: @start, end: @end})
      else
        Dayinfo.create(employee_id: id, date: @date, start: @start, end: @end)
      end
    end
    redirect_to daily_index_path(day: params[:day])
  end

  def destroy
    @employee.destroy
    redirect_to daily_index_path(list: params[:list]), notice: "社員を削除しました"
  end

  private
    def set_data
      @tday = params[:day] || (@date = Date.current).to_s
      @date ||= Date.parse(@tday)
      @employees = @company.employees.preload(:emp_status, :work_template, :ex_vals).order(:no)
      @emp_exes = @company.emp_exes.order(:id)
    end
    def set_employee
      @employee = Employee.find(params[:id])
    end
    def employee_params
      params.require(:employee).permit(:company_code, :no, :name, :email, :password, :password_confirmation, emp_emp_status_attributes: [:company_id, :employee_id, :emp_status_id])
    end
end
