class CreateHolidays < ActiveRecord::Migration[5.2]
  def change
    create_table :holidays do |t|
      t.integer :emp_status_id
      t.date :date

      t.timestamps
    end
  end
end
