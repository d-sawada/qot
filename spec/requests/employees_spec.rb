require 'rails_helper'

RSpec.describe "Employees", type: :request do
  describe "GET /employees" do
    it "works! (now write some real specs)" do
      get daily_index_employee_path
      expect(response).to have_http_status(200)
    end
  end
end
