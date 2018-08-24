module ApplicationHelper
  def signed_in?
    sys_admin_signed_in? || admin_signed_in? || employee_signed_in?
  end
  def admins_signed_in?
    sys_admin_signed_in? || admin_signed_in?
  end
  def employees_signed_in?
    sys_admin_signed_in? || employee_signed_in?
  end
  def check_company(kind)
    code = params[:company_code]
    if code.prisent? && Company.find_by_code(code).present?
      redirect_to "/#{code}/#{kind}/signed_in", alert: "ログインが必要です"
    else
      redirect_to notice_company_url, alert: "会社コードを入力してください"
    end
  end
  def authenticate_admins_company
    check_company("admin") unless admins_signed_in?
  end
  def authenticate_employees_company
    check_company("employee") unless employees_signed_in?
  end
  def authenticate_company
    redirect_to notice_company_url, alert: "会社コードを入力してください" unless signed_in?
  end
end

class Object
  def in(*args)
    args.each {|v|return true if self == v}
    false
  end
end

class Integer
  def sel_to_hm
    ("0" + (self / 3600).to_s).slice(-2, 2) + ":" + ("0" + ((self % 3600) / 60).to_s).slice(-2, 2)
  end
  def min_to_times
    (self / 60).to_s + ":" + (self % 60 < 10 ? "0" + (self % 60).to_s : (self % 60).to_s)
  end
  def apply_rest
    if self >= 480
      self - 60
    elsif self >= 360
      self - 45
    end
  end
end

class Float
  def to_hm
    x = self.to_i
    ("0" + (x / 3600).to_s).slice(-2, 2) + ":" + ("0" + ((x % 3600) / 60).to_s).slice(-2, 2)
  end
end

class DateTime
  def to_hm
    self.strftime("%h:%M")
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
  def to_daily
    date = Date.parse(self)
    date.strftime("%Y年%-m月%-d日(") + %w(日 月 火 水 木 金 土)[date.wday] + ")"
  end
  def to_monthly
    Date.parse(self).strftime("%Y年%-m月")
  end
end
