class CompaniesController < ApplicationController
  def setting
    @employee_additional_labels = @company.employee_additional_labels
    @employee_additional_label = EmployeeAdditionalLabel.new
    @employee_additional_label.company_code = @company_code
  end
end
