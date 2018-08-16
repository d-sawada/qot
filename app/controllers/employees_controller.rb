class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  def index
    @list_type = params[:list] || "day"
    @target_day = params[:day] || Date.current.to_s

    #========== カラム ==========
    @employee_labels = ["名前"]
    @add_labels = @company.employee_additional_labels
    @all_labels = @employee_labels + @add_labels.pluck(:name)

    #========== 社員情報一覧 ==========
    @employees = @company.employees.includes(:dayinfos, :employee_additional_values).order(:id)

    @add_values = []
    @employees.each do |employee|
      add_value = {}
      employee.employee_additional_values.each do |value|
        add_value[value.employee_additional_label_id] = value.value
      end
      @add_values << add_value
    end

    if @list_type == "day"
      @dayinfo_labels = ["所定出勤", "所定退勤", "出勤打刻", "退勤打刻"]
      @all_labels += @dayinfo_labels
      @all_dayinfos = []
      @employees.each do |employee|
        all_dayinfo = {}
        employee.dayinfos.each do |d|
          if d.date.to_s == @target_day
            @dayinfo_labels.zip([d.pre_start, d.pre_end, d.start, d.end]).each { |key, val| all_dayinfo[key] = val.to_s.slice(11, 5) if val.present? }
          end
        end
        @all_dayinfos << all_dayinfo
      end
    elsif @list_type == "month"
      @monthinfo_labels = ["勤務日数", "所定時間", "出勤日数", "実働計"]
      @all_labels += @monthinfo_labels
      @all_monthinfos = []
      @employees.each do |employee|
        all_monthinfo = Hash[@monthinfo_labels.zip([0, 0, 0, 0])]
        employee.dayinfos.each do |d|
          if d.date.to_s.slice(0, 7) == @target_day.slice(0, 7)
            if d.pre_start.present? && d.pre_end.present?
              all_monthinfo["勤務日数"] += 1
              all_monthinfo["所定時間"] += (d.pre_end - d.pre_start).to_i
            end
            if d.start.present? && d.end.present?
              all_monthinfo["出勤日数"] += 1
              all_monthinfo["実働計"] += (d.end - d.start).to_i
            end
          end
        end
        all_monthinfo["所定時間"] = (all_monthinfo["所定時間"]).to_hm
        all_monthinfo["実働計"] = (all_monthinfo["実働計"]).to_hm
        @all_monthinfos << all_monthinfo
      end
    elsif @list_type == "schedule"
      day_num = Date.parse(@target_day).end_of_month.day.to_i
      @days_labels = (1..day_num).to_a
      @all_labels += @days_labels
    end
  end

  def show
    @list_type = params[:list] || "day"
    @target_day = params[:day] || Date.current.to_s
    @date = Date.parse(@target_day)
    @day_num = @date.end_of_month.day.to_i

    @all_labels = []
    if @list_type == "day"
      d = @employee.dayinfos.where("date = ?", @target_day).first
      @dayinfo = d.present? ? [d.pre_start, d.pre_end, d.start, d.end].map{|v| v.present? ? v.to_s.slice(11, 5) : ""}
                                   : ["", "", "", ""]
      @all_labels += ["所定出勤", "所定退勤", "出勤打刻", "退勤打刻"]
    elsif @list_type == "month"
      @dayinfos = Hash[*@employee.dayinfos.where("date >= ? AND date <= ?", @date.beginning_of_month.to_s, @date.end_of_month.to_s)
          .map{ |d| [d.date.to_s.slice(-2, 2), [d.pre_start, d.pre_end, d.start, d.end].map{|v| v.to_s.slice(11, 5)}]}.flatten(1)]
      @all_labels += ["日", "所定出勤", "所定退勤", "出勤打刻", "退勤打刻"]
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
