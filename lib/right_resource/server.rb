class Server < RightResource::Base
  class << self
    #TODO: refactor define_method or method_missing
    def action; end
    # server start(Starting created instance)
    # === Examples
    #   server_id = Server.index(:filter => "nickname=dev001").first.id
    #   Server.start(server_id)
    def start(id)
      connection.post(element_path(id, :start))
    end

    # server stop(Starting created instance)
    def stop(id)
      connection.post(element_path(id, :stop))
    end

    # server restart(Starting created instance)
    def reboot(id)
      connection.post(element_path(id, :reboot))
    end

    # Run rightscript
    # location header is status href
    def run_script(id, params={})
      raise NotImplementedError
    end

    def attach_volume(id, params={})
      raise NotImplementedError
    end

    def get_sketchy_data(id, params={})
      raise NotImplementedError
    end

    def settings(id)
      path = element_path(id, :settings)
      generate_attributes(format.decode(connection.get(path)))
    end
  end
end
