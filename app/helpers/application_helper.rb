module ApplicationHelper
  def signed_in?
    sys_admin_signed_in? || admin_signed_in? || employee_signed_in?
  end
end

class Integer
  def to_hm
    ("0" + (self / 3600).to_s).slice(-2, 2) + ":" + ("0" + ((self % 3600) / 60).to_s).slice(-2, 2)
  end
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
end

class String
  def month_begin
    Date.parse(self).beginning_of_month.to_s
  end
  def month_end
    Date.parse(self).end_of_month.to_s
  end
end
