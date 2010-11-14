# == define_methods
# * _set_
# * _unset_
# === Examples
#   Set tags for a resource
#     ec2_href = Server.show(1).current_instance_href
#     params = {:resource_href => ec2_href, :tags => ["xx99_server:role=dev", "xx99_server:group=dev"]}
#     Tag.set(params)
#     puts Tag.status
#     p Tag.search(:resource_href => ec2_href)
#   Unset tags for a resource
#     Tag.unset(params)
#     puts Tag.status
#     p Tag.search(:resource_href => ec2_href)
class Tag < RightResource::Base
  class << self
    undef :index, :show, :create, :update, :destory

    [:set, :unset].each do |act_method|
      define_method(act_method) do |params|
        path = "#{get_tag_resource_path(act_method)}"
        action(:put, path, params)
      end
    end

    # Search tags for a resource(resource_href in params) or resources matching giving tags
    # === Parameters
    # * +params+ - Hash (keys = [:resource_href or :resource_type, :match_all, :tags])
    # === Return
    # Array(tags)
    # === Examples
    #   Get tags for a resource
    #     Tag.search(:resource_href => "/ec2_instances/1")
    #
    #   Get resources matching tags
    #     param = {:resource_type => "ec2_instance", :tags => ["x99_db:role=*"]}
    #     servers = Tag.search(p).select {|server| server[:state] == "operational"}.map do |resource|
    #       Server.new(resource)
    #     end
    #
    #     param = {:resource_type => "ec2_instance", :match_all => 'true', :tags => ["x99_db:role=slave"]}
    #     servers = Tag.search(p).select {|server| server[:state] == "operational"}.map do |resource|
    #       Server.new(resource)
    #     end
    def search(params)
      path = "#{get_tag_resource_path("search")}.#{format.extension}#{query_string(params)}"
      result = format.decode(action(:get, path)).map do |tags|
        tags.generate_attributes
      end
    end

    # === Examples
    #   Tag.taggable_resources
    def taggable_resources
#      "#{self.name.to_s.split('::').last}s/#{__method__}" if RUBY_VERSION >= "1.8.7"
      path = get_tag_resource_path("taggable_resources")
      RightResource::Formats::XmlFormat.decode(action(:get, path))
    end

    private
    def get_tag_resource_path(method_name)
      "#{self.name.to_s.split('::').last.downcase}s/#{method_name}"
    end
  end
  undef :create, :update, :destory
end
