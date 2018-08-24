class CreateWorkPatterns < ActiveRecord::Migration[5.2]
  def change
    create_table :work_patterns do |t|
      t.string :name,        null: false
      t.datetime :start,     null: false
      t.datetime :end,       null: false
      t.string :start_day,   null: false
      t.string :end_day,     null: false
      t.integer :company_id, null: false

      t.timestamps
    end
  end
end
