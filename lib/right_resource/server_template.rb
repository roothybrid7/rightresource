class ServerTemplate < RightResource::Base
  class << self
    # === Parameters
    # * _id_ - ServerTemplate id
    # * _params_ - Hash (keys = [:phase]) ex. 'boot', 'operational', 'decommission' if not defined, all phases
    def executables(id, params={})
      path = element_path(id, :executables, params)
      format.decode(connection.get(path)).map {|resource| correct_attributes(resource)}
    end
  end
end
