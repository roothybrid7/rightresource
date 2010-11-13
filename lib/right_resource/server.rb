class Server < RightResource::Base
  class << self
    def action(method, path, params={})
      case method
      when :get
        connection.get(path, params)
      when :post
        connection.post(path, params)
      end
    rescue RestClient::ResourceNotFound
      nil
    rescue => e
      logger.error("#{e.class}: #{e.pretty_inspect}")
      logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
    ensure
      logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
    end

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
    # * +params+ -  (ex. https://my.rightscale.com/right_scripts/{id})
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

    # ===Examples
    #   server_id = 848422
    #   params = {:start => -180, :end => -20, :plugin_name => "cpu-0", :plugin_type => "cpu-idle"}
    #   Server.get_sketchy_data(server_id, params)
    def get_sketchy_data(id, params)
      path = element_path(id, :get_sketchy_data, params)
      generate_attributes(format.decode(action(:get, path)))
    end

    def monitoring(id, params={})
      raise NotImplementedError
#      if params[:graph_name]
#        prefix_options = params[:graph_name]
#        params.delete(:graph_name)
#        path = element_path(id, {:monitoring => prefix_options}, params)
#      else
#        path = element_path(id, :monitoring, params)
#      end
#      generate_attributes(format.decode(action(:get, path)))
    end

    # Get Server settings(Subresource)
    # === Examples
    #   server_id = Server.index(:filter => "nickname=dev-001").first.id
    #   settings = Server.settings(server_id)
    def settings(id)
      path = element_path(id, :settings)
      generate_attributes(format.decode(action(:get, path)))
    end

    # Get Server tags(server or ec2_current_instance)
    # === Parameters
    #   +resource_href+ - server.href or server.ec2_current_href
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
