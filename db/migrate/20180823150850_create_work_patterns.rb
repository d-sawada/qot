class CreateWorkPatterns < ActiveRecord::Migration[5.2]
  def change
    create_table :work_patterns do |t|
      t.integer :company_id,    null: false
      t.string :name,           null: false
      t.datetime :start,        null: false
      t.datetime :end,          null: false
      t.datetime :rest_start
      t.datetime :rest_end
      t.string :start_day,      null: false
      t.string :end_day,        null: false
      t.string :rest_start_day
      t.string :rest_end_day

      t.timestamps
    end
  end
end
