class ServerArray < RightResource::Base
  class << self
    # server array launch
    # ==== Parameters
    # * +id+ - RightScale server array resource id(https://my.rightscale.com/server_arrays/{id})
    #
    # === Examples
    #   array_id = 1
    #   ServerArray.launch(array_id)
    def launch(id)
      path = element_path(id, :launch)
      action(:post, path)
    end

    # server array terminate all
    # === Examples
    #   ServerArray.terminate_all(1)
    #   # => {:ec2_instances=>{"failure"=>[],
    #          "success"=>[{"ec2_instance_href"=>"https://my.rightscale.com/api/acct/##/ec2_instances/1367"}]}}
    def terminate_all(id)
      path = element_path(id, :terminate_all)
      generate_attributes(format.decode(action(:post, path)))
    end

    # Run script on all
    # === Exception
    # * +NotImplementedError+
    def run_script_on_all(id, params)
      raise NotImplementedError
#      pair = URI.decode({resource_name.to_sym => params}.to_params).split('&').map {|l| l.split('=')}
#      h = Hash[*pair.flatten]
#      path = element_path(id, :run_script_on_all)
#      action(:post, path, h)
    end

    def instances(id)
      path = element_path(id, :instances)
      result = format.decode(action(:get, path)).map do |instance|
        generate_attributes(instance)
      end
    end
  end
end
