class Object
  def in(*args)
    args.each {|v|return true if self == v}
    false
  end
end
