class Deployment < RightResource::Base
  class << self
    def start_all(id)
      connection.post(element_path(id, :start_all => nil))
    end

    def stop_all(id)
      connection.post(element_path(id, :stop_all => nil))
    end

    def duplicate(id)
      connection.post(element_path(id, :duplicate => nil))
    end
  end

  def start_all
    connection.post(element_path(:start_all => nil))
  end

  def stop_all
    connection.post(element_path(:stop_all => nil))
  end

  def duplicate
    connection.post(element_path(:duplicate => nil))
  end
end
