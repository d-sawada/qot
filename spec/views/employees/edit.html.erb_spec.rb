require 'rails_helper'

RSpec.describe "employees/edit", type: :view do
  before(:each) do
    @employee = assign(:employee, Employee.create!(
      :email => "MyString",
      :password => "MyString",
      :password_confirmation => "MyString"
    ))
  end

  it "renders the edit employee form" do
    render

    assert_select "form[action=?][method=?]", employee_path(@employee), "post" do

      assert_select "input[name=?]", "employee[email]"

      assert_select "input[name=?]", "employee[password]"

      assert_select "input[name=?]", "employee[password_confirmation]"
    end
  end
end
