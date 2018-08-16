module ApplicationHelper
end

class Integer
  def to_hm
    ("0" + (self / 3600).to_s).slice(-2, 2) + ":" + ("0" + ((self % 3600) / 60).to_s).slice(-2, 2)
  end
end
