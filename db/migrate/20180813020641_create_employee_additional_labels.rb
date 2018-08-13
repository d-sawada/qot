class CreateEmployeeAdditionalLabels < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_additional_labels do |t|
      t.string :company_code, null: false, limit: 6
      t.string :name, null: false, limit: 8

      t.timestamps
    end
  end
end
