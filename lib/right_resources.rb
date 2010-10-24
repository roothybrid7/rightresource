#!/usr/bin/env ruby
# @author Satoshi Ohki

require 'rubygems'
require 'rest_client'

module RightResource
  class Base
    class << self
      #attr_accessor :instances, :user, :pass, :account, :format
      attr_accessor :instances
      def connection(refresh=false)
        if defined?(@connection) || superclass == Object
          @connection = Connection.new(format) if refresh || @connection.nil?
          @connection.login(:username => user, :password => pass, :account => account)
          @connection
        else
          superclass.connection
        end
      end
      def format=(type)
        @format = type.to_s.sub("json", "js")
      end
      def format
        @format || "xml"
      end
      def headers
      end
      def element_path(id, prefix_options={}, query_options=nil)
        "#{resource_name}#{prefix_path(prefix_options)}.#{format}#{query_string(query_options)}"
      end

      # CRUD Operations
      # :all, :first, :last
      # example: (servers)params = {
      #   :filter => "private_ip_address=10.1.1.1"
      #   :filter => "nickname=web-001"
      # }
      def index(params={})
        path = "#{resource_name}.#{format}#{query_string(params)}"
        connection.get(path || [])
      end

      def show(id, params={})
        path = "#{resource_name}/#{id}.#{format}#{query_string(params)}"
        connection.get(path || [])
  #      self.class.new
      end

      def resource_name
        self.to_s.split(/::/).last.to_s.downcase + "s"
      end

      def collection_path
      end

      def instantiate_collection(collection, prefix_option={})
        collection.collect! {|record| instantiate_record(record, prefix_options)}
      end

      def instantiate_record(record, prefix_options={})
        self.class.new(record)
      end

      def query_string(options)
        query = ""
        options.each do |key,value|
          query << query.empty? ? "?#{key.to_s}=#{value}" : "&#{key.to_s}=#{value}"
        end
      end
    end

    def initialize(attributes={})
      @attributes = attributes
      @id = connection.resource_id ||= attributes["href"].match(/\d+$/) if attributes["href"]
      if attributes
        attributes.each_pair do |key, value|
          instance_variable_set('@' + key, value)
        end
      end
    end

    protected
    def store
      self.class.instances ||= []
      self.class.instances << self
    end

    def connection(refresh=false)
      self.class.connection(refresh)
    end

    # get data and update
    def update(id, params={})
      @connection.put(path, encode, self.class.headers)
    end

    # get data and create(Clone)
    def create(params={})
      @connection.post(path, encode, self.class.headers) do |response|
  #      self.id = response.body
      end
    end

    def destroy(id)
      @connection.delete(path, self.class.headers)
    end
  end
end

# Management API
class Management < RightResource::Base; end

class Deployment < Management
end

class Server < Management
end

class Status < Management
end

class AlertSpec < Management
end

class Ec2EbsVolume < Management
end

class Ec2EbsSnapshot < Management
end

class Ec2ElasticIP < Management
end

class Ec2SecurityGroup < Management
end

class Ec2SshKeys < Management
end

class ServerArray < Management
end

class S3Bucket < Management
end

class Tag < Management
end

class VpcDhcpOption < Management
end

# Design API
class Design < RightResource::Base; end

class ServerTemplate < Design
end

class RightScript < Design
end

class MultiCloudImage < Design
end

class Macro < Design
end

class Credential < Design
end
