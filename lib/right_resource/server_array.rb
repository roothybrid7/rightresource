class ServerArray < RightResource::Base
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

    # server array actions (launch, terminate_all)
    # ==== Parameters
    # * +id+ - RightScale server array resource id(https://my.rightscale.com/server_arrays/{id})
    #
    # === Examples
    #   array_id = 1
    #   ServerArray.launch(array_id)
    [:launch, :terminate_all].each do |act_method|
      define_method(act_method) do |id|
        path = element_path(id, act_method)#.sub(/\.#{format.extension}$/, '')
        action(:post, path)
      end
    end

    def run_script_on_all(id, params)
      raise NotImplementedError
#      pair = URI.decode({resource_name.to_sym => params}.to_params).split('&').map {|l| l.split('=')}
#      h = Hash[*pair.flatten]
#      path = element_path(id, :run_script_on_all).sub(/\.#{format.extension}$/, '')
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
