# Ruby version < 1.9
class Object
  def tap
    yield self
    self
  end
end
