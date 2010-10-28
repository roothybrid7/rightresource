class S3Bucket < RightResource::Base
  class << self
    def update(id)
      raise NotImplementedError
    end
  end

  def update
    raise NotImplementedError
  end
end
