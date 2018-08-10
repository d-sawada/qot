class ApplicationController < ActionController::Base
  before_action :set_company

  protected
  def set_company
    @company_code = params[:company_code]
    @company = Company.find_by(code: @company_code) if @company_code
  end
end
