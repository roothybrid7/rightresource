class Server < RightResource::Base
  class << self
    # server actions (start, stop, restart)
    # ==== Parameters
    # * +id+ - RightScale server resource id(https://my.rightscale.com/servers/{id})
    #
    # === Examples
    #   server_id = Server.index(:filter => "nickname=dev001").first.id
    #   Server.start(server_id)
    [:start, :stop, :reboot].each do |act_method|
      define_method(act_method) do |id|
        path = element_path(id, act_method).sub(/\.#{format.extension}$/, '')
        action(:post, path)
      end
    end

    # === Parameters
    # * +params+ - Hash, resource parameters (ex. https://my.rightscale.com/right_scripts/{id})
    #
    # === Examples
    #   server_id = 1
    #   params = {:ec2_ebs_volume_href => "https://my.rightscale.com/api/acct/##/ec2_ebs_volumes/1", :device => "/dev/sdj"}
    #   Server.attach_volume(server_id, params) # => 204 No Content
    [:run_script, :attach_volume].each do |act_method|
      define_method(act_method) do |id,params|
        elems = params.reject {|key,value| key == :right_script}  # select server resource params
        pair = URI.decode({resource_name.to_sym => elems}.to_params).split('&').map {|l| l.split('=')}
        h = Hash[*pair.flatten]
        h["right_script"] = params[:right_script] if params.has_key?(:right_script)
        path = element_path(id, act_method)
        action(:post, path, h)
      end
    end

    # Get sampleing data
    # === Return
    #   Hash (keys # => [:cf, :start, :vars, :lag_time, :end, :data :avg_lag_time])
    # === Examples
    #   server_id = 848422
    #   params = {:start => -180, :end => -20, :plugin_name => "cpu-0", :plugin_type => "cpu-idle"}
    #   Server.get_sketchy_data(server_id, params)
    def get_sketchy_data(id, params)
      path = element_path(id, :get_sketchy_data, params)
      generate_attributes(format.decode(action(:get, path)))
    end

    # Get URL of Server monitoring graph
    # === Examples
    #   * General Graph
    #     Server.monitoring(1)
    #
    #   * Custumize Graph
    #     server_id = 1
    #     params = {:graph_name => "cpu-0/cpu-idle", :size => "small", :period => "day", :title => "MyCpuGraph", :tz => "JST"}
    #     Server.monitoring(server_id, params)
    def monitoring(id, params={})
      if params[:graph_name]
        prefix_options = params[:graph_name]
        params.delete(:graph_name)
        path = element_path(id, :monitoring => prefix_options)
      else
        path = element_path(id, :monitoring)
      end
      generate_attributes(format.decode(action(:get, path, params)))
    end

    # Get Server settings(Subresource)
    # === Examples
    #   server_id = Server.index(:filter => "nickname=dev-001").first.id
    #   settings = Server.settings(server_id)
    def settings(id)
      path = element_path(id, :settings)
      generate_attributes(format.decode(action(:get, path)))
    end

    # Get status of any running jobs after calling to the servers resource to run_script
    # === Parameters
    # * +resource_ref+ - Hash[:id] or Hash[:href](execute run_script method response location header)
    #                   (ex. Location: https://my.rightscale.com/api/acct/##/statuses/{id})
    # === Examples
    #   server_id = 1
    #   right_script_id = 1
    #   Server.run_script(server_id, :right_script => right_script_id)
    #   # => 201 Created, location: https://my.rightscale.com/api/acct/##/statuses/12345
    #
    #   Server.statuses(:id => Server.resource_id) if Server.status == 201
    #   or
    #   Server.statuses(:href => Server.headers[:location]) if Server.status == 201
    def statuses(resource_ref)
      path = element_path(id, :get_sketchy_data, params)
      generate_attributes(format.decode(action(:get, path)))
    end

    # Get Server tags(server or ec2_current_instance)
    # === Parameters
    # * +resource_href+ - server.href or server.ec2_current_href
    # === Examples
    #   server = Server.show(1)
    #   tags = Server.tags(server.ec2_current_href)
    #   # => [{"name"=>"rs_login:state=active"}, {"name"=>"rs_logging:state=active"}, {"name"=>"rs_monitoring:state=active"}]
    def tags(resource_href)
      query_options = {:resource_href => resource_href}
      path = "tags/search.#{format.extension}#{query_string(query_options)}"
      Hash[*format.decode(action(:get, path)).collect {|tag|
        tag['name'].split('=')
      }.flatten]
    end
  end
end
