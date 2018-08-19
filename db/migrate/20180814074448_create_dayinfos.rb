class CreateDayinfos < ActiveRecord::Migration[5.2]
  def change
    create_table :dayinfos do |t|
      t.integer :employee_id, null: false
      t.date :date, null: false
      t.datetime :pre_start
      t.datetime :pre_end
      t.datetime :start
      t.datetime :end
      t.datetime :rest_start
      t.datetime :rest_end

      t.timestamps
    end
  end
end
