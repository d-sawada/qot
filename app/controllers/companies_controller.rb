class CompaniesController < ApplicationController
  before_action :authenticate_admin! unless sys_admin_signed_in?

  def setting

  end
end
