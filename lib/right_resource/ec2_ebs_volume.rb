class Ec2EbsVolume < RightResource::Base
  class << self
    # Eb2Volume attach to server
    # === Parameters
    # * +params+ - Hash (keys = [:ec2_ebs_volume_href, :component_href, :device, :mount])
    def component_ec2_ebs_volumes(params)
      pair = URI.decode({:component_ec2_ebs_volume => elems}.to_params).split('&').map {|l| l.split('=')}
      h = Hash[*pair.flatten]
      path = "component_ec2_ebs_volumes"
      action(:post, path, h)
    end
    alias_method :attach_to_server, :component_ec2_ebs_volumes
  end
end
