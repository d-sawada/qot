class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.integer :employee_id, null: false
      t.integer :admin_id
      t.string :state, null: false
      t.string :date, null: false
      t.datetime :prev_start
      t.datetime :prev_end
      t.datetime :start
      t.datetime :end
      t.text :employee_comment, limit: 255
      t.text :admin_comment, limit: 255

      t.timestamps
    end
  end
end
