module ApplicationConstant
  DETAIL_LINK = "詳細"
  REQUEST_LINK = "打刻修正を登録"
  EDIT_LINK = "編集"
  DELETE_LINK = "削除"
  CANCEL = "やめる"
  DELETE = "削除する"
  LOGED_IN = "ログイン中"
  CHECK = "✔︎"

  WDAY_SYMS_FROM_MON = [:mon, :tue, :wed, :thu, :fri, :sat, :sun]
  WDAY_SYMS_FROM_SUN = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]

  PATTERN_DAILY_INDEX_KEYS = %w(パターン名 所定出勤 所定退勤 所定休始 所定休終)
  PATTERN_DAILY_SHOW_KEYS = %w(パターン名 所定出勤 所定退勤 所定休始 所定休終)
  # PATTERN_MONTHLY_INDEX_KEYS = ""
  PATTERN_MONTHLY_SHOW_KEYS = %w(パターン名 所定出勤 所定退勤 所定休始 所定休終)

  DAYINFO_DAILY_INDEX_KEYS = %w(出勤打刻 退勤打刻)
  DAYINFO_DAILY_SHOW_KEYS = %w(出勤打刻 退勤打刻)
  DAYINFO_MONTHLY_INDEX_KEYS = %w(所定日数 所定時間 出勤日数 所定内 休出日数 休出時間)
  DAYINFO_MONTHLY_SHOW_KEYS = %w(所定日数 所定時間 出勤日数 所定内 休出日数 休出時間)
end
