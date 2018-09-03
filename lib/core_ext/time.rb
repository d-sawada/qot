class Time
  def to_hm
    self.to_s.slice(11, 5)
  end
end
