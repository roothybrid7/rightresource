class RightScript < RightResource::Base
  class << self
    undef :create, :destory
  end
  undef :create, :update, :destory
end
