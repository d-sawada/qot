class EmployeesController < ApplicationController
  include EmployeesHelper
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  def index
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    date = Date.parse(@tday)

    if @list == "day"
      #@employees = @company.employees.select("employees.*, dayinfos.*").references(:dayinfos).left_joins(:dayinfos)
      emp_syms = [:no, :status, :name]
      day_syms = [:pre_start, :pre_end, :start, :end, :rest_start, :rest_end]
      @employees = @company.employees
      dayinfos = Hash[@company.dayinfos.where(dayinfos: {date: date}).map{|d| [d.employee_id, d]}]
      @table_keys = employee_daily_keys
      @table_rows = @employees.map do |emp|
        dayinfo = dayinfos[emp.id] || Dayinfo.new
        emp_syms.map{|sym| emp[sym]} + day_syms.map{|sym| dayinfo[sym].to_hm}
      end
    elsif @list == "month"

    elsif @list == "schedule"

    end
  end

  def show
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    @day_num = Date.parse(@tday).end_of_month.day.to_i

    day_symkeys = [:pre_start, :pre_end, :start, :end].zip(%w(所定出勤 所定退勤 出勤打刻 退勤打刻))
    if @list == "day"
      day = @employee.dayinfos.where("date = ?", @tday).first
      day_val = day.present? ? day_symkeys.map{|sym, key| day.try(sym).to_hm} : ["","","",""]
      @table_key = day_symkeys.map{|sym,key| key}
      @table_vals = [day_val]
    elsif @list == "month"
      days = @employee.dayinfos.where("date >= ? AND date <= ?", @tday.month_begin, @tday.month_end)
      day_vals = days.map{|day| [day.date.day, day_symkeys.map{|sym,key| day.try(sym).to_hm}]}
      @table_key = day_symkeys.map{|sym,key| key}
      @table_vals = (1..@day_num).map{ @table_key.map{ "" } }
      day_vals.each{|val| @table_vals[val[0]-1] = val[1]}
    elsif @list == "schedule"

    end
  end

  def new
    @employee = Employee.new
  end

  def edit
    @labels = @company.employee_additional_labels.map{ |label| [label.id, label.name] }.to_h
    @default_values = @employee.employee_additional_values.map{ |val| [@labels[val.employee_additional_label_id], val.value] }.to_h
  end

  def create
    @employee = Employee.new(employee_params)

    respond_to do |format|
      if @employee.save
        format.html { redirect_to @employee, notice: 'Employee was successfully created.' }
        format.json { render :show, status: :created, location: @employee }
      else
        format.html { render :new }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @employee.update(employee_params)
        params[:employee][:employee_additional_values].each do |name, value|
          @employee.employee_additional_values.find_by_employee_additional_label_id(@company.employee_additional_labels.find_by_name(name).id).update({value: value})
          #EmployeeAdditionalValue.update({employee_id: @employee.id, employee_additional_label_id: @company.employee_additional_labels.find_by_name(name).id, value: value})
        end
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
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
      params.require(:employee).permit(:name, :email, :password, :password_confirmation)
    end
end
