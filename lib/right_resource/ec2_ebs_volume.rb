class Ec2EbsVolume < RightResource::Base
  class << self
    def attach_to_server
      name = "component_ec2_ebs_volumes"
      raise NotImplementedError
    end
  end
end
