class Status < RightResource::Base
  class << self
    undef :index, :create, :update, :destory
  end
  undef :create, :update, :destory
end
