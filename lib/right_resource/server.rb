#!/usr/bin/env ruby
# Author:: Satoshi Ohki <roothybrid7@gmail.com>

class Server < RightResource::Base
  class << self
    def settings(id, params={})
      path = "#{resource_name}s/#{id}/#{__method__.to_s}.#{format}#{query_string(params)}"
      instantiate_record(JSON.parse(connection.get(path)))
    end
  end

  def settings
    path = "#{@resource_name}s/#{@id}/#{__method__.to_s}.#{self.class.format}"
    sub_attrs = generate_attributes(JSON.parse(connection.get(path)))
    self.attributes.merge! sub_attrs
    load_accessor(sub_attrs)
  end
end
