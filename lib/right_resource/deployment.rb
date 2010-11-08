class Deployment < RightResource::Base
  class << self
    def start_all(id)
      connection.post(element_path(id, :start_all))
    end

    def stop_all(id)
      connection.post(element_path(id, :stop_all))
    end

    def duplicate(id)
      connection.post(element_path(id, :duplicate))
    end
  end
end
