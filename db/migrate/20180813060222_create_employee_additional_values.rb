class CreateEmployeeAdditionalValues < ActiveRecord::Migration[5.2]
  def change
    create_table :employee_additional_values do |t|
      t.integer :employee_id, null: false
      t.string :name, null: false, limit: 8
      t.string :value, null: false, default: "", limit: 255

      t.timestamps
    end
  end
end
