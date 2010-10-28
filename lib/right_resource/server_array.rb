class ServerArray < RightResource::Base
  class << self
    def launch(id)
      connection.post(element_path(id, :launch => nil))
    end

    def terminate_all(id)
      connection.post(element_path(id, :terminate_all => nil))
    end

    def run_script_on_all(id)
      raise NotImplementedError
    end

    def instances(id)
      path = element_path(id, :instances => nil)
      instantiate_collection(format.decode(connection.get(path)))
    end
  end

  def launch
    connection.post(element_path(:launch => nil))
  end

  def terminate_all
    connection.post(element_path(:terminate_all => nil))
  end

  def run_script_on_all
    raise NotImplementedError
  end

  def instances
    path = element_path(:instances => nil)
    instances = self.class.instantiate_collection(self.class.format.decode(connection.get(path)))
    if instances.size > 0
      self.attributes[:active_instances] = []
      instances.each do |ins|
        self.attributes[:active_instances] << ins.attributes
      end
      load_accessor(:active_instances => self.attributes[:active_instances])
    end
    self
  end
end
