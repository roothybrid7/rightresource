class ServerArray < RightResource::Base
  class << self
    def instances(id, params={})
      path = "#{resource_name}s/#{id}/#{__method__.to_s}.#{format.extension}#{query_string(params)}"
      instantiate_collection(format.decode(connection.get(path)))
    end
  end

  def instances
    path = "#{@resource_name}s/#{@id}/#{__method__.to_s}.#{self.class.format.extension}"
    instances = self.class.instantiate_collection(self.class.format.decode(connection.get(path)))
    if instances.size > 0
      self.attributes[:active_instances] = []
      instances.each do |ins|
        link_id = ins.resource_uid.gsub('-', '_').to_s
        self.attributes[:active_instances] << {link_id.to_sym => ins.attributes}
      end
      load_accessor(:active_instances => self.attributes[:active_instances])
    end
    self
  end
end
