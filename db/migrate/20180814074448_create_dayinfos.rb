class CreateDayinfos < ActiveRecord::Migration[5.2]
  def change
    create_table :dayinfos do |t|
      t.string :date, null: false
      t.string :start
      t.string :end
      t.string :pre_start
      t.string :pre_end
      t.integer :employee_id, null: false

      t.timestamps
    end
  end
end
