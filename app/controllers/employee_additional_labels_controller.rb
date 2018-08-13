class EmployeeAdditionalLabelsController < ApplicationController
  def create
    @employee_additional_label = EmployeeAdditionalLabel.new(employee_params)

    if @employee_additional_label.save
      respond_to do |format|
        format.js
      end
    end
  end

  def destroy
    @employee_additional_label = EmployeeAdditionalLabel.find(params[:id])
    @employee_additional_label.destroy

    respond_to do |format| format.js end
  end

  private
  def employee_params
    params.require(:employee_additional_label).permit(:company_code, :name)
  end
end
