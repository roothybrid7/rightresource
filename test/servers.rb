#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json/pure'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")
p $LOAD_PATH

require "lib/right_connection.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}
# convert key.type: String2Symbol
$login_params = {}
auth_data.each_pair {|key,value| $login_params[key.to_sym] = value}
p $login_params.inspect

module RightResource
  class Base
  #class Server
    class << self
      def connection
        @connection = Connection.new
        @connection.format = "js"
        @connection.login($login_params)
        @connection
      end

      def index(params={})
        path = "#{resource_name}.#{format}#{query_string(params)}"
        instantiate_collection(JSON.parse(connection.get(path || [])))
      end

      def show(id, params={})
        path = "#{resource_name}/#{id}.#{format}#{query_string(params)}"
        instantiate_record(JSON.parse(connection.get(path)))
      end

      def resource_name
        self.name.split(/::/).last.to_s.downcase + "s"
      end

      def query_string(options)
        unless options.nil? || options.empty?
          query = ""
          options.each do |key,value|
            query << query.empty? ? "?#{key.to_s}=#{value}" : "&#{key.to_s}=#{value}"
          end
        end
      end

      def format=(type)
        @format = type.to_s.sub("json", "js")
      end

      def format
        @format || "js"
      end

      def instantiate_collection(collection)
        collection.collect! {|record| instantiate_record(record)}
      end

      def instantiate_record(record)
        self.new(record)
      end
    end

    def initialize(attributes={})
      @attributes = attributes
      @id = attributes["href"].match(/\d+$/) if attributes["href"]
      if attributes
        attributes.each_pair do |key, value|
          instance_variable_set('@' + key, value)
          eval("def #{key}; @#{key} end")
          eval("def #{key}=(#{key}); @#{key} = #{key} end") 
        end
      end
    end
    attr_reader :attributes
  end
end

class Server < RightResource::Base; end

# Entry point
server = Server.show("838755")
p server
p server.attributes['nickname']
p server.nickname
exit 0
#servers.each do |s|
#p "BEGIN Id: #{s.href.match(/\d+$/)} Nickname: #{s.nickname} -----"
#  puts "State: #{s.state}"
#  p s.attributes
#p "--------------------- END"
#end

puts "END OF SCRIPT"
exit 0
