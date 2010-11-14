class MultiCloudImage < RightResource::Base
  class << self
    undef :create, :update, :destory
  end
  undef :create, :update, :destory
end
