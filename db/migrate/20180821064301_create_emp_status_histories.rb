class CreateEmpStatusHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :emp_status_histories do |t|
      t.date :start
      t.date :end
      t.string :emp_status_str
      t.integer :employee_id

      t.timestamps
    end
  end
end
