# == Define methods
# deployment actions (start_all, stop_all, duplicate)
# ==== Parameters
# * +id+ - RightScale deployment resource id(https://my.rightscale.com/deployments/{id})
class Deployment < RightResource::Base
  class << self
    # Override RightResource::Base#index
    # Hash2Object of RightScale servers
    def index(params = {})
      deployments = super
      deployments.each do |deployment|
        deployment.servers
      end

      deployments
    end

    # Override RightResource::Base#show
    # Hash2Object of RightScale servers
    def show(id, params = {})
      deployment = super
      unless deployment.nil?
        deployment.servers
      end

      deployment
    end

    [:start_all, :stop_all, :duplicate].each do |act_method|
      define_method(act_method) do |id|
        path = element_path(id, act_method).sub(/\.#{format.extension}$/, '') # response empty and format xml only
        action(:post, path)
      end
    end
  end

  # Convert servers
  def servers
    unless self.attributes[:servers].nil?
      self.attributes[:servers].map! do |record|
        record.is_a?(Hash) ? Server.new(record) : record
      end
    end

    self.attributes[:servers]
  end
end
