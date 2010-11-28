class Ec2ElasticIp < RightResource::Base
  class << self
    undef :update
  end
  undef :update
end
