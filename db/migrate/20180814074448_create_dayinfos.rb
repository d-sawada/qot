class CreateDayinfos < ActiveRecord::Migration[5.2]
  def change
    create_table :dayinfos do |t|
      t.integer :employee_id
      t.date :date
      t.datetime :pre_start
      t.datetime :pre_end
      t.datetime :start
      t.datetime :end
      t.datetime :rest_start
      t.datetime :rest_end

      # 集計用
      t.integer :pre_workdays  # 所定出勤日数
      t.integer :pre_worktimes # 所定勤務時間（分）
      t.integer :workdays      # 出勤日数
      t.integer :worktimes     # 実働時間（分）
      t.integer :holiday_workdays  # 休日出勤日数
      t.integer :holiday_worktimes # 休日勤務時間（分）

      t.timestamps
    end
  end
end
