class CreateEmpStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :emp_statuses do |t|
      t.string :company_code, null: false
      t.string :name, null: false
      t.integer :work_template_id, null: false

      t.timestamps
    end
  end
end
