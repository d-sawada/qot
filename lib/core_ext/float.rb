class Float
  def to_hm
    x = self.to_i
    ("0" + (x / 3600).to_s).slice(-2, 2) + ":" +
    ("0" + ((x % 3600) / 60).to_s).slice(-2, 2)
  end
end
