class EmployeesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_admins_company,
                only: [:daily_index, :monthly_index, :index, :new, :edit,
                       :create, :update, :destroy]
  before_action :authenticate_company, only: [:show]
  before_action :set_employee, only: [:edit, :update, :destroy]
  before_action :set_index_common_data, only: [:daily_index, :monthly_index]

  def daily_index
    csv_keys = set_daily_index_keys

    patterns = @company.work_patterns
    @pattern_by_id = Hash[patterns.map{ |pattern| [pattern.id, pattern] }]

    dayinfos = @company.dayinfos.where(dayinfos: {date: @date})
    dayinfo_by_emp_id = Hash[dayinfos.map{|d| [d.employee_id, d]}]

    csv_rows, @table_rows = [], []

    @employees.each do |emp|
      csv_row = daily_index_csv_row(emp, dayinfo_by_emp_id)
      csv_rows << csv_row
      @table_rows << [checkbox(:employee, emp.id)] + csv_row +
                     [emp.detail_link(@tday, "day")]
    end

    index_csv_format(csv_keys, csv_rows, @date.strftime("QoT%Y-%m-%d.csv"))
  end

  def monthly_index
    dayinfos = @company.dayinfos.monthly(@date)
    dayinfo_by_emp_id = Hash[dayinfos.map{ |d| [d.employee_id, d] }]

    csv_keys = employee_monthly_index_keys(@emp_exes.pluck(:name)) +
               DAYINFO_MONTHLY_INDEX_KEYS

    @table_keys = [CHECK] + csv_keys + [DETAIL_LINK]

    csv_rows, @table_rows = [], []

    @employees.each do |emp|
      dayinfo = dayinfo_by_emp_id[emp.id] || Dayinfo.new
      id_to_ex_vals = Hash[emp.ex_vals.pluck(:emp_ex_id, :value)]
      ex_vals = @emp_exes.map{ |ex| id_to_ex_vals[ex.id] || "" }

      csv_row = emp.monthly_index_row(ex_vals) + dayinfo.monthly_index_row
      csv_rows << csv_row
      @table_rows << [checkbox(:employee, emp.id)] + csv_row +
                     [emp.detail_link(@tday, "month")]
    end

    index_csv_format(csv_keys, csv_rows, @date.strftime("QoT%Y-%m.csv"))
  end

  def show
    @employee = Employee.find(params[:id]) if admins_signed_in?
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    @date = Date.parse(@tday)
    day_num = @date.end_of_month.day.to_i

    if @list == "day"
      dayinfo = @employee.dayinfos.where("date = ?", @tday).first || Dayinfo.new
      table_csv_keys = PATTERN_DAILY_SHOW_KEYS + DAYINFO_DAILY_SHOW_KEYS
      table_opt_keys = ["申請登録"]
      row =
        (WorkPattern.find_by_id(@employee.work_template.pattern_id_of(@date)) ||
        WorkPattern.new).daily_show_row + dayinfo.daily_show_row
      table_csv_rows = [row]
      table_opt_rows = [[@employee.request_link(@tday)]]
    elsif @list == "month"
      sum_dayinfo =  @employee.dayinfos.monthly(@date)[0]
      sum_dayinfo ||= Dayinfo.new
      @sum_dayinfo_keys = DAYINFO_MONTHLY_SHOW_KEYS
      @sum_dayinfo_rows = [sum_dayinfo.monthly_show_row]

      dayinfos = @employee.dayinfos.where("date between ? and ?",
                                          @tday.month_begin, @tday.month_end)
      dayinfos = Hash[dayinfos.map{ |d| [d.date.day, d] }]
      work_patterns =
        Hash[@company.work_patterns.map{|pattern| [pattern.id, pattern]}]
      table_csv_keys = ["日付"] + PATTERN_DAILY_SHOW_KEYS +
                       DAYINFO_DAILY_SHOW_KEYS
      table_opt_keys = %w(詳細 申請登録)
      table_csv_rows = []
      table_opt_rows = []
      (1..day_num).each do |i|
        dayinfo = dayinfos[i] || Dayinfo.new
        pattern_id = dayinfo.work_pattern_id ||
                     @employee.work_template.pattern_id_of(@date.change(day: i))
        pattern = work_patterns[pattern_id] || WorkPattern.new
        table_csv_rows << [i] + pattern.daily_show_row +
                          dayinfo.daily_show_row
        table_opt_rows << [
          @employee.detail_link(@date.change(day: i), "day"),
          @employee.request_link(@date.change(day: i))
        ]
      end
    end

    @table_keys = table_csv_keys + table_opt_keys
    @table_rows = table_csv_rows.zip(table_opt_rows).map{|x,y| x + y}

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate do |csv|
          csv << table_csv_keys
          table_csv_rows.each{|row| csv << row }
        end
        filename = "Qot" +
                   @date.strftime(@list == "day" ? "%Y-%m-%-d" : "%Y-%m") +
                   "-#{@employee.name}" + ".csv"
        send_data(csv_data, filename: filename)
      end
      format.html
    end
  end

  def new
    @employee = @company.employees
                  .new(password: "password", password_confirmation: "password")
    @emp_statuses = @company.emp_statuses
    @emp_exes = @company.emp_exes
    @ex_vals = {}
  end

  def edit
    @emp_statuses = @company.emp_statuses
    @emp_exes = @company.emp_exes
    @ex_vals = Hash[@employee.ex_vals.pluck(:emp_ex_id, :vlaue)]
  end

  def create
    @employee = Employee.new(employee_params)
    @company.emp_exes.each do |ex|
      @employee.ex_vals.build(emp_ex_id: ex.id, value: params[:emp_ex][ex.name])
    end

    if @employee.save
      redirect_to daily_index_path, notice: '社員を登録しました'
    else
      @emp_statuses = @company.emp_statuses
      @emp_exes = @company.emp_exes
      @ex_vals = Hash[@company.emp_exes
                  .map{ |ex| [ex.id, params[:emp_ex][ex.name]] }]
      render :new
    end
  end

  def update
    @company.emp_exes.each do |ex|
      @employee.ex_vals.build(emp_ex_id: ex.id, value: params[:emp_ex][ex.name])
    end

    if @employee.upudate(employee_params)
      redirect_to @employee, notice: "社員情報を更新しました"
    else
      @emp_statuses = @company.emp_statuses
      @emp_exes = @company.emp_exes
      @ex_vals = Hash[@company.emp_exes
                  .map{ |ex| [ex.id, params[:emp_ex][ex.name]] }]
      render :edit
    end
  end

  def setting
    @tab_datas = %w(設定).zip(%w(setting))
                   .map{ |title, render| {title: title, render: render} }
  end

  def update_setting
    @employee.update(employee_params)
  end

  def bulk_action
    @ids = params[:employee].pluck(:id)
    action = params[:bulk_action]

    unless @ids && action.in("bulk_change_pattern", "bulk_request")
      return redirect_to_daily_index
    end

    if action == "bulk_change_pattern"
      employees = Employee.where("id in (#{@ids.join(",")})").preload(:dayinfos)
      employees.each do |emp|
        dayinfo = emp.dayinfos.where("date = ?", params[:day])
        dayinfo.update({work_pattern_id: params[:pattern_id]}) if dayinfo
      end
    else # bulk_request
      @date = Date.parse(params[:day]) || Date.current
      return render :bulk_create_requests
    end

    redirect_to_daily_index
  end

  def bulk_create_requests
    @ids = params[:ids].map(&:to_i)

    return unless @ids

    @date = params[:date]
    @start = params[:start]
    @end = params[:end]
    @admin_comment = params[:admin_comment]

    dayinfos =
      Dayinfo.left_joins(:employee)
        .where("dayinfos.date = ? and employees.id in (?)", @date, @ids)
        .select("id, employee_id, start, end")
        .map{ |r| [r.employee_id, {id: r.id, start: r.start, end: r.end}] }

    emp_id_to_dayinfo = Hash[dayinfos]

    @ids.each do |id|
      Request.create(
        employee_id: id,
        admin_id: @admin.id,
        state: "承認済",
        date: @date,
        start: @start,
        end: @end,
        admin_comment: @admin_comment,
        prev_start: emp_id_to_dayinfo[id][:start],
        prev_end: emp_id_to_dayinfo[id][:end]
      )

      dayinfo = Dayinfo.find_by_id(emp_id_to_dayinfo[id][:id])

      if dayinfo
        dayinfo.update(start: @start, end: @end)
      else
        Dayinfo.create(employee_id: id, date: @date, start: @start, end: @end)
      end
    end

    redirect_to_daily_index
  end

  def destroy
    @employee.destroy
    redirect_to daily_index_path(list: params[:list]), notice: "社員を削除しました"
  end

  private

  def set_index_common_data
    @tday = params[:day] || (@date = Date.current).to_s
    @date ||= Date.parse(@tday)
    @employees = @company.employees
                   .preload(:emp_status, :work_template, :ex_vals).order(:no)
    @emp_exes = @company.emp_exes.order(:id)
  end

  def set_daily_index_keys
    csv_keys = employee_daily_index_keys(@emp_exes.pluck(:name)) +
               PATTERN_DAILY_INDEX_KEYS +
               DAYINFO_DAILY_INDEX_KEYS

    @table_keys = [CHECK] + csv_keys + [DETAIL_LINK]
    csv_keys
  end

  def daily_index_csv_row(employee, dayinfo_by_emp_id)
    dayinfo = dayinfo_by_emp_id[employee.id] || Dayinfo.new

    id = dayinfo.work_pattern_id || employee.work_template.pattern_id_of(@date)
    pattern = @pattern_by_id[id] || WorkPattern.new

    id_to_ex_vals = Hash[employee.ex_vals.pluck(:emp_ex_id, :value)]
    ex_vals = @emp_exes.map{ |ex| id_to_ex_vals[ex.id] || "" }

    csv_row = employee.daily_index_row(ex_vals) +
              pattern.daily_index_row +
              dayinfo.daily_index_row
  end

  def index_csv_format(csv_keys, csv_rows, filename)
    respond_to do |format|
      format.csv do
        csv_data = CSV.generate do |csv|
          csv << csv_keys
          csv_rows.each{ |row| csv << row }
        end
        send_data(csv_data, filename: filename)
      end
      format.html
    end
  end

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def redirect_to_daily_index(target_day = params[:day])
    redirect_to daily_index_path(day: target_day)
  end

  def employee_params
    params.require(:employee)
      .permit(
        :company_code, :no, :name, :email, :has_password,
        :password, :password_confirmation,
        emp_emp_status_attributes: [:company_id, :employee_id, :emp_status_id]
      )
  end
end
