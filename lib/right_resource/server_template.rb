class ServerTemplate < RightResource::Base
  class << self
    def executables(id, params={})
      path = element_path(id, {:executables => nil}, params)
      instantiate_collection(format.decode(connection.get(path)))
    end
  end

  def executables(params={})
    path = element_path({:executables => nil}, params)
    exec = self.class.instantiate_collection(self.class.format.decode(connection.get(path)))
    if exec.size > 0
      self.attributes[:executables] = []
      exec.each do |ins|
        self.attributes[:executables] << exec.attributes
      end
      load_accessor(:executables => self.attributes[:executables])
    end
    self
  end
end
