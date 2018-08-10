require 'rails_helper'

RSpec.describe "employees/new", type: :view do
  before(:each) do
    assign(:employee, Employee.new(
      :email => "MyString",
      :password => "MyString",
      :password_confirmation => "MyString"
    ))
  end

  it "renders new employee form" do
    render

    assert_select "form[action=?][method=?]", employees_path, "post" do

      assert_select "input[name=?]", "employee[email]"

      assert_select "input[name=?]", "employee[password]"

      assert_select "input[name=?]", "employee[password_confirmation]"
    end
  end
end
