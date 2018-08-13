require 'rails_helper'

RSpec.describe CompaniesController, type: :controller do

  describe "GET #config" do
    it "returns http success" do
      get :config
      expect(response).to have_http_status(:success)
    end
  end

end
