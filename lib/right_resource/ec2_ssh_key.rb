class Ec2SshKey < RightResource::Base
  class << self
    def index(id)
      raise NotImplementedError
    end
  end

  def index
    raise NotImplementedError
  end
end
