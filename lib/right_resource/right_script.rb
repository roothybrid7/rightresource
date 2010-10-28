class RightScript < RightResource::Base
  class << self
    def create
      raise NotImplementedError
    end

    def update(id)
      raise NotImplementedError
    end

    def destory(id)
      raise NotImplementedError
    end
  end

  def create
    raise NotImplementedError
  end

  def update(id)
    raise NotImplementedError
  end

  def destory(id)
    raise NotImplementedError
  end
end
