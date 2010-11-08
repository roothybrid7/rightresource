class Ec2SshKey < RightResource::Base
  class << self
    def index(id)
      raise NotImplementedError
    end
  end
end
