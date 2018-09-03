class String
  def month_begin
    Date.parse(self).beginning_of_month.to_s
  end

  def month_end
    Date.parse(self).end_of_month.to_s
  end

  def to_daily
    date = Date.parse(self)
    date.strftime("%Y年%-m月%-d日(") + %w(日 月 火 水 木 金 土)[date.wday] + ")"
  end

  def to_monthly 
    Date.parse(self).strftime("%Y年%-m月")
  end
end
