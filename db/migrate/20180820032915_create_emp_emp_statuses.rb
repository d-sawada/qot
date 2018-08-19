class CreateEmpEmpStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :emp_emp_statuses do |t|
      t.integer :company_id
      t.integer :employee_id
      t.integer :emp_status_id

      t.timestamps
    end
  end
end
