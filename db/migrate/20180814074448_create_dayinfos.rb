class CreateDayinfos < ActiveRecord::Migration[5.2]
  def change
    create_table :dayinfos do |t|
      t.string :date, null: false
      t.string :start, null: false, default: ""
      t.string :end, null: false, default: ""
      t.string :pre_start, null: false, default: ""
      t.string :pre_end, null: false, default: ""
      t.integer :employee_id, null: false

      t.timestamps
    end
  end
end
