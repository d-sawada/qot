module EmployeesHelper
  def employee_daily_keys
    %w(社員No 雇用形態 名前 所定出勤 所定退勤 出勤打刻 退勤打刻 休憩開始 休憩終了)
  end
  def employee_monthly_keys
    %w(社員No 雇用形態 名前 勤務日数 所定時間 出勤日数 実働計 休出日数 休出時間)
  end
end
