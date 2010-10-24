#!/usr/bin/env ruby
# Author:: Satoshi Ohki <roothybrid7@gmail.com>

module RightResource
  class Base
  #class Server
    class << self
      def set_auth(user, password, account=nil)
        self.user = user
        self.password = password
        self.account = account unless account.nil?
      end

      def user
        if defined?(@user)
          @user
        elsif superclass != Object && superclass.user
          superclass.user.dup.freeze
        end
      end

      def user=(user)
        @connection = nil
        @user = user
      end

      def password
        if defined?(@password)
          @password
        elsif superclass != Object && superclass.password
          superclass.password.dup.freeze
        end
      end

      def password=(password)
        @connection = nil
        @password = password
      end

      def account
        if defined?(@account)
          @account
        elsif superclass != Object && superclass.account
          superclass.account.dup.freeze
        end
      end

      def account=(account)
        @connection = nil
        @account = account
      end

      def format=(type)
        @format = type
      end

      def format
        @format || RightResource::Formats::JsonFormat
      end

#      def connection(refresh=false)
      def connection
        if defined?(@connection) || superclass == Object
          @connection = Connection.new
          @connection.format = format
          @connection.username = user if user
          @connection.password = password if password
          @connection.account = account if account
          @connection.login()
          @connection
        else
          superclass.connection
        end
      end

      def headers
        @connection.headers || {}
      end

      def resource_id
        @connection.resource_id || nil
      end

      def index(params={})
        path = "#{resource_name}s.#{format.extension}#{query_string(params)}"
        instantiate_collection(format.decode(connection.get(path || [])))
      end

      def show(id, params={})
        path = "#{resource_name}s/#{id}.#{format.extension}#{query_string(params)}"
        instantiate_record(format.decode(connection.get(path)))
      end

      def resource_name
        index = 0
        name = ""
        self.name.split(/::/).last.to_s.each_char do |c|
          if /[A-Z]/ =~ c && index > 0
            name << "_#{c.downcase}"
          else
            name << c.downcase
          end
          index += 1
        end
        name
      end

      def query_string(options)
        query = ""
        unless options.nil? || options.empty?
          options.each do |key,value|
            if query.empty? 
              query << "?#{key.to_s}=#{value}"
            else
              query << "&#{key.to_s}=#{value}"
            end
          end
        end
        query
      end

      def instantiate_collection(collection)
        collection.collect! {|record| instantiate_record(record)}
      end

      def instantiate_record(record)
        self.new(record)
      end
    end

    def initialize(attributes={})
      @resource_name = self.class.resource_name
      @headers = self.class.headers || {}
      @resource_id = self.class.resource_id || nil
      # sub-resource4json's key name contains '-'
      attrs = generate_attributes(attributes)
      if attrs
        @attributes = attrs
        @id = attrs[:href].match(/\d+$/).to_s if attrs[:href]
        load_accessor(attrs)
      end
    end
    attr_reader :attributes, :resource_name, :headers, :resource_id, :id
    def generate_attributes(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      attrs = {}
      attributes.each_pair {|key,value| attrs[key.gsub('-', '_').to_sym] = value}
      attrs
    end

    def load_accessor(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.inspect}" unless attributes.is_a?(Hash)
      attributes.each_pair do |key, value|
        instance_variable_set('@' + key.to_s, value)
        eval("def #{key.to_s}; @#{key.to_s} end")
        eval("def #{key.to_s}=(#{key.to_s}); @#{key.to_s} = #{key.to_s} end")
      end
    end

    protected
      def connection
        self.class.connection
      end
  end
end
