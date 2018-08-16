class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def nil.method_missing(*_);nil;end
end

class Float
  def to_hm
    x = self.to_i
    ("0" + (x / 3600).to_s).slice(-2, 2) + ":" + ("0" + ((x % 3600) / 60).to_s).slice(-2, 2)
  end
end

class Time
  def to_hm
    self.to_s.slice(11, 5)
  end
  def trunc_sec
    Time.at(self.to_i / 60 * 60)
  end
end

class String
  def month_begin
    Date.parse(self).beginning_of_month.to_s
  end
  def month_end
    Date.parse(self).end_of_month.to_s
  end
end