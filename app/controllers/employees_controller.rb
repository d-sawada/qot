class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  def index
    @list = params[:list] || "day"
    @tday = params[:day] || Date.current.to_s
    emp_symkeys = [].zip(%w())#[:name].zip(%w(名前))
    ex_keys = @company.employee_additional_labels

    emps = @company.employees.includes(:dayinfos, :employee_additional_values).order(:id)
    ex_vals_hashs = emps.map{|emp| Hash[emp.ex_vals.map{|val| [val.ex_key_id, val.value]}] }
    ex_vals = ex_vals_hashs.map{|hashs| ex_keys.map{|key| hashs[key.id]}}

    @link_tds = emps.map{|emp| {id: emp.id, name: emp.name}}
    @table_key = ["名前"]

    if @list == "day"
      day_symkeys = [:pre_start, :pre_end, :start, :end].zip(%w(所定出勤 所定退勤 出勤打刻 退勤打刻))
      days = emps.map{|emp| emp.dayinfos.where("date = ?", @tday).first}
      day_vals = days.map{|day| day_symkeys.map{|sym, key| day.try(sym).to_hm}}
      @table_key += emp_symkeys.map{|s,k| k} + ex_keys.pluck(:name) + day_symkeys.map{|sym,key| key}
      @table_vals = emps.zip(ex_vals, day_vals).map{|emp, val, day| emp_symkeys.map{|sym,key| emp[sym]} + val + day}
    elsif @list == "month"
      day_keys = %w(勤務日数 所定時間 出勤日数 実働計)
      dayss = emps.map{|emp| emp.dayinfos.where("date >= ? AND date <= ?", @tday.month_begin, @tday.month_end)}
      day_vals = dayss.map{|days| days.map{|day| day.totalization}.transpose}.map{|a1,a2,a3,a4| [a1.sum, a2.sum, a3.sum, a4.sum.to_hm]}
      @table_key += emp_symkeys.map{|sym,key| key} + ex_keys.pluck(:name) + day_keys
      @table_vals = emps.zip(ex_vals, day_vals).map{|emp, val, day| emp_symkeys.map{|sym,key| emp[sym]} + val + day}
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
      @table_vals = (1..@day_num).map{ ["","","",""] }
      day_vals.each{|val| @table_vals[val[0]] = val[1]}
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
