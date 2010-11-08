class Server < RightResource::Base
  class << self
    def action; end
    def start(id)
      connection.post(element_path(id, :start))
    end

    def stop(id)
      connection.post(element_path(id, :stop))
    end

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
      format.decode(connection.get(path))
    end
  end
end
