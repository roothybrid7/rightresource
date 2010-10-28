class Server < RightResource::Base
  class << self
    def start(id)
      connection.post(element_path(id, :start => nil))
    end

    def stop(id)
      connection.post(element_path(id, :stop => nil))
    end

    def reboot(id)
      connection.post(element_path(id, :reboot => nil))
    end

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
      path = element_path(id, :settings => nil)
      instantiate_record(format.decode(connection.get(path)))
    end
  end

  def start
    connection.post(element_path(:start => nil))
  end

  def stop(id)
    connection.post(element_path(:stop => nil))
  end

  def reboot(id)
    connection.post(element_path(:reboot => nil))
  end

  def run_script(id, params={})
    raise NotImplementedError
  end

  def attach_volume(id, params={})
    raise NotImplementedError
  end

  def get_sketchy_data(id, params={})
    raise NotImplementedError
  end

  def settings
    path = element_path(:settings => nil)
    sub_attrs = generate_attributes(self.class.format.decode(connection.get(path)))
    self.attributes.merge! sub_attrs
    load_accessor(sub_attrs)
  end
end
