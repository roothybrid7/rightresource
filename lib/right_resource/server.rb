# == define_methods 1
# Server Action
# * _start_
# * _stop_
# * _restart_
#
# === Parameters
# * _id_ - RightScale server resource id(https://my.rightscale.com/servers/{id})
# === Examples
#   server_id = Server.index(:filter => "nickname=dev001").first.id
#   Server.start(server_id)
#
# == define_methods 2
# Server and other resource action
# * _run_script_
# * _attach_volume_
# === Parameters
# * _id_ - RightScale server resource id(https://my.rightscale.com/servers/{id})
# * _params_ - Hash(ex. :right_script, :ec2_ebs_volume_href, :device)
# === Examples
#   server_id = 1
#   params = {:ec2_ebs_volume_href => "https://my.rightscale.com/api/acct/##/ec2_ebs_volumes/1", :device => "/dev/sdj"}
#   Server.attach_volume(server_id, params) # => 204 No Content
class Server < RightResource::Base
  class << self
    [:start, :stop, :reboot].each do |act_method|
      define_method(act_method) do |id|
        path = element_path(id, act_method).sub(/\.#{format.extension}$/, '') # can't include json extension in request
        action(:post, path)
      end
    end

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

    # Get Current instance of server
    def show_current(id, params={})
      path = element_path(id, :current, params)
      connection.clear
      result = format.decode(connection.get(path)).tap do |resource|
        correct_attributes(resource)
      end
      instantiate_record(result).tap do |resource|
        resource.id = resource.href.sub(/\/current$/, "").match(/[0-9]+$/).to_s.to_i
      end
    rescue => e
      logger.error("#{e.class}: #{e.pretty_inspect}")
      logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
      nil
    ensure
      logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
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
      format.decode(action(:get, path)).tap {|resource| correct_attributes(resource)}
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
      format.decode(action(:get, path, params)).tap {|resource| correct_attributes(resource)}
    end

    # Get Server settings(Subresource)
    # === Examples
    #   server_id = Server.index(:filter => "nickname=dev-001").first.id
    #   settings = Server.settings(server_id)
    def settings(id)
      path = element_path(id, :settings)
      format.decode(action(:get, path)).tap {|resource| correct_attributes(resource)}
    end

    # Get Server tags(server or ec2_current_instance)
    # === Parameters
    # * +resource_href+ - server.href or server.ec2_current_href
    # === Examples
    #   server = Server.show(1)
    #   tags = Server.tags(server.ec2_current_href)
    #   # => [{"rs_login:state" => "active"}, {"name"=>"rs_logging:state=active"}, {"name"=>"rs_monitoring:state=active"}]
    def tags(resource_href)
      query_options = {:resource_href => resource_href}
      path = "tags/search.#{format.extension}#{query_string(query_options)}"
      Hash[*format.decode(action(:get, path)).collect {|tag|
        tag['name'].split('=')
      }.flatten]
    end
  end

  # Get Server settings with merge to instance(attributes[:settings])
  # === Examples
  #   server = Server.index(:filter => "nickname=dev-001").first
  #   Server.settings
  #   # => Server#attributes[:settings]
  #   # {:dns_name => "ec2-175-...", :aws_id => "i-12345", ..., :ip_address => "175...."}
  def settings
    # first access
    if self.attributes[:settings].nil?
      self.attributes[:settings] = _settings
    end

    self.attributes[:settings]
  end

  # Get Server settings with merge to instance(destructive)
  # === Examples
  #   server = Server.index(:filter => "nickname=dev-001").first
  #   Server.settings!
  #   # => self
  #   #
  #   # > Server.attributes
  #   # => [:nickname => "server1", :aws_id => "i-12345", ..., :ip_address => "175..."]
  def settings!
    self.loads(_settings)

    self
  end

  private
    def _settings
      self.class.settings(self.id) rescue nil
    end
end
