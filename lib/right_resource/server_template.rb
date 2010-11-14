class ServerTemplate < RightResource::Base
  class << self
    # === Parameters
    # * _id_ - ServerTemplate id
    # * _params_ - Hash (keys = [:phase]) ex. 'boot', 'operational', 'decommission'
    def executables(id, params={})
      path = element_path(id, :executables, params)
      format.decode(connection.get(path)).map {|x| x.generate_attributes}
    end
  end
end
