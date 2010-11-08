class ServerTemplate < RightResource::Base
  class << self
    def executables(id, params={})
      path = element_path(id, :executables, params)
      instantiate_collection(format.decode(connection.get(path)))
    end
  end
end
