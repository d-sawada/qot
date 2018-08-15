class EmployeesController < ApplicationController
  before_action :set_employee, only: [:show, :edit, :update, :destroy]

  # GET /employees
  # GET /employees.json
  def index
    @list_type = params[:list] || "day"
    @today = Date.today.to_s.delete("-")

    #========== カラム ==========
    @labels = @company.employee_additional_labels
    @all_labels = ["メールアドレス"] + @labels.pluck(:name)

    #========== 社員情報一覧 ==========
    q = '*'
    i = 1
    @labels.each do |label|
      q += ", (SELECT \"employee_additional_values\".\"value\" FROM \"employee_additional_values\" WHERE \"employee_additional_values\".\"employee_id\" = \"employees\".\"id\" AND \"employee_additional_values\".\"employee_additional_label_id\" = #{label.id} ) AS \"ex#{i}\""
      i += 1
    end
    @employees = Employee.select(q).left_joins(:dayinfos).references(:dayinfos).where("dayinfos.date = ? OR dayinfos.date is NULL", @today) if @list_type == "day"
    @employees = Employee.select(q).includes(:dayinfos).references(:dayinfos).where("(dayinfos.date >= ? AND dayinfos.date <= ?) OR dayinfos.date is NULL", @today.slice(0,6) + "01", @today.slice(0,6) + "31") if @list_type == "month" || @list_type == "schedule"
  end

  # GET /employees/1
  # GET /employees/1.json
  def show
  end

  # GET /employees/new
  def new
    @employee = Employee.new
  end

  # GET /employees/1/edit
  def edit
  end

  # POST /employees
  # POST /employees.json
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

  # PATCH/PUT /employees/1
  # PATCH/PUT /employees/1.json
  def update
    respond_to do |format|
      if @employee.update(employee_params)
        format.html { redirect_to @employee, notice: 'Employee was successfully updated.' }
        format.json { render :show, status: :ok, location: @employee }
      else
        format.html { render :edit }
        format.json { render json: @employee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /employees/1
  # DELETE /employees/1.json
  def destroy
    @employee.destroy
    respond_to do |format|
      format.html { redirect_to employees_url(list: params[:list]), notice: '従業員を削除しました.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_employee
      @employee = Employee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def employee_params
      params.require(:employee).permit(:email, :password, :password_confirmation)
    end
end
