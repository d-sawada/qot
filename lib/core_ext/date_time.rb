class DateTime
  def to_hm
    self.strftime("%h:%M")
  end

  def change!(**option)
    self.replace(self.change(option))
  end

  def yesterday!
    self.replace(self.yesterday)
  end

  def tommorrow!
    self.replace(self.tommorrow!)
  end
end
