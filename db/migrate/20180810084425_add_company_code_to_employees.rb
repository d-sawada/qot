class AddCompanyCodeToEmployees < ActiveRecord::Migration[5.2]
  def change
    add_column :employees, :company_code, :string, null: false, default: "", limit: 6
  end
end
