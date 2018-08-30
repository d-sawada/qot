class CreateEmpExes < ActiveRecord::Migration[5.2]
  def change
    create_table :emp_exes do |t|
      t.integer :company_id
      t.string :name

      t.timestamps
    end
  end
end
