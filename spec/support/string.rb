#monkey patching color methods form Term::ANSIColor
class String
  def green
    self
  end

  def red
    self
  end

  def blue
    self
  end

  def white
    self
  end
end