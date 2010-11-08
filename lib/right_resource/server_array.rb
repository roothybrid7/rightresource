class ServerArray < RightResource::Base
  class << self
    def launch(id)
      connection.post(element_path(id, :launch))
    end

    def terminate_all(id)
      connection.post(element_path(id, :terminate_all))
    end

    def run_script_on_all(id)
      raise NotImplementedError
    end

    def instances(id)
      path = element_path(id, :instances)
      format.decode(connection.get(path))
    end
  end
end
