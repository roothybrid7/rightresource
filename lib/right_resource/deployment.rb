# == Define methods
# deployment actions (start_all, stop_all, duplicate)
# ==== Parameters
# * +id+ - RightScale deployment resource id(https://my.rightscale.com/deployments/{id})
class Deployment < RightResource::Base
  class << self
    [:start_all, :stop_all, :duplicate].each do |act_method|
      define_method(act_method) do |id|
        path = element_path(id, act_method).sub(/\.#{format.extension}$/, '') # response empty and format xml only
        action(:post, path)
      end
    end
  end
end
