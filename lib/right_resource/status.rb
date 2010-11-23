class Status < RightResource::Base
  class << self
    undef :index, :create, :destory
  end
  undef :create, :update, :destory
end
