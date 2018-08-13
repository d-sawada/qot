class AdminsController < ApplicationController
  def index
    @admins = @company.admins
  end
end
