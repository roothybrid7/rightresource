class Ec2ElasticIp < RightResource::Base
  class << self
    def update(id)
      raise NotImplementedError
    end
  end

  def update
    raise NotImplementedError
  end
end
