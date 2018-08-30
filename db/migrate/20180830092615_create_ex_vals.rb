class CreateExVals < ActiveRecord::Migration[5.2]
  def change
    create_table :ex_vals do |t|
      t.integer :emp_ex_id
      t.integer :employee_id
      t.string :value

      t.timestamps
    end
  end
end
