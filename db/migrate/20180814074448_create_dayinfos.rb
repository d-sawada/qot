class CreateDayinfos < ActiveRecord::Migration[5.2]
  def change
    create_table :dayinfos do |t|
      t.integer :employee_id, null: false
      t.date :date, null: false
      t.time :start
      t.time :end
      t.time :pre_start
      t.time :pre_end

      t.timestamps
    end
  end
end
