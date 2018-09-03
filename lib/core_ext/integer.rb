class Integer
  def sec_to_hm
    ("0" + (self / 3600).to_s).slice(-2, 2) + ":" +
    ("0" + ((self % 3600) / 60).to_s).slice(-2, 2)
  end

  def min_to_times
    (self / 60).to_s + ":" + (self % 60 < 10 ? "0" +
    (self % 60).to_s : (self % 60).to_s)
  end

  def apply_rest
    if self >= 480
      self - 60
    elsif self >= 360
      self - 45
    else
      self
    end
  end
end
