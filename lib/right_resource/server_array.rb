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
      format.decode(action(:post, path)).tap {|resource| correct_attributes(resource)}
    end

    # Run script on all(Response format is only xml)
    # === Examples
    #   RightResource::Base.connection = RightResource::Connection.new do |c|
    #     c.login(:username => "user", :password => "pass", :account => "1")
    #   end
    #   array_id = 1
    #   scripts_params = {
    #     :right_script_href => "#{RightResource::Base.connection.api}###/right_scripts/261296",
    #     :server_template_hrefs => ["#{RightResource::Base.connection.api}###/server_templates/83632"],
    #   }
    #
    #   ServerArray.run_script_on_all(array_id, scripts_params)
    #   => {:audit_entries=>
    #         [{:href=>"https://my.rightscale.com/api/acct/###/audit_entries/44723645"},
    #          {:href=>"https://my.rightscale.com/api/acct/###/audit_entries/44723646"}]}
    def run_script_on_all(id, params)
      pair = URI.decode({resource_name.to_sym => params}.to_params).split('&').map {|l| l.split('=')}
      h = Hash[*pair.flatten]
      path = element_path(id, :run_script_on_all).sub(/\.#{format.extension}$/, '') # xml only
      RightResource::Formats::XmlFormat.decode(action(:post, path, h)).tap {|resource| correct_attributes(resource)}
    end

    # Get Server Array instances(subresource)
    # === Examples
    #   array_id = ServerArray.index.first.id
    #   instances = ServerArray.instances(array_id)
    #   => [{:nickname => "web #1", :resource_uid => "i-12345", ...},
    #      {:nickname => "web #2", :resource_uid => "i-67890", ...}]
    def instances(id)
      path = element_path(id, :instances)
      format.decode(action(:get, path)).map do |instance|
        correct_attributes(instance)
      end
    end
  end

  # Get Server Array with merge to ServerArray instance(attributes[:instances])
  # === Examples
  #   array = ServerArray.index.first
  #   array.instances
  #   # => ServerArray#attributes[:instances]
  #   => [{:nickname => "web #1", :resource_uid => "i-12345", ...},
  #      {:nickname => "web #2", :resource_uid => "i-67890", ...}]
  def instances
    # first access
    if self.attributes[:instances].nil?
      self.attributes[:instances] = self.class.instances(self.id) rescue nil
    end

    self.attributes[:instances]
  end
end
