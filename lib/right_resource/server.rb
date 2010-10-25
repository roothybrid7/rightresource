class Server < RightResource::Base
  class << self
    def settings(id, params={})
      path = "#{resource_name}s/#{id}/settings.#{format.extension}#{query_string(params)}"
      instantiate_record(format.decode(connection.get(path)))
    end
  end

  def settings
    path = "#{@resource_name}s/#{@id}/settings.#{self.class.format.extension}"
    sub_attrs = generate_attributes(self.class.format.decode(connection.get(path)))
    self.attributes.merge! sub_attrs
    load_accessor(sub_attrs)
  end
end
