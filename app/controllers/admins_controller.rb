class AdminsController < ApplicationController
  include ApplicationHelper
  
  before_action :authenticate_admins_company
end
