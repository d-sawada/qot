class AddCompamyCodeToAdmins < ActiveRecord::Migration[5.2]
  def change
    add_column :admins, :company_code, :string, null: false, limit: 6, default: ""
  end
end
