class CreateWorkTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :work_templates do |t|
      t.integer :company_id, null: false
      t.string :name, null: false
      t.integer :mon
      t.integer :tue
      t.integer :wed
      t.integer :thu
      t.integer :fri
      t.integer :sat
      t.integer :sun

      t.timestamps
    end
  end
end
