class Ec2SecurityGroup < RightResource::Base
  class << self
    def index(id)
      raise NotImplementedError
    end

    def update(id)
      raise NotImplementedError
    end
  end
end
