module RightResource
  class Base
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
        @format ||= RightResource::Formats::JsonFormat
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

      def show(id, prefix={}, params={})
        path = element_path(id, prefix, params)
        instantiate_record(format.decode(connection.get(path)))
      end

      def destory(id)
        path = "#{resource_name}s/#{id}.#{format.extension}"
        connection.delete(path)
      end

      def element_path(id, prefix_options = {}, query_options = nil)
        "#{resource_name}s/#{id.to_s}#{prefix(prefix_options)}.#{format.extension}#{query_string(query_options)}"
      end

      def collection_path(prefix_options = {}, query_options = nil)
        "#{resource_name}s#{prefix(prefix_options)}.#{format.extension}#{query_string(query_options)}"
      end

      def resource_name
        name = ""
        self.name.to_s.split(/::/).last.scan(/([A-Z][^A-Z]*)/).flatten.each_with_index do |str,i|
          if i > 0
            name << "_#{str.downcase}"
          else
            name << str.downcase
          end
        end
        name
      end

      def prefix(options={})
        default = ""
        unless options.nil? || options.empty?
          options.each do |key,value|
            if value.nil? || value.empty?
              default << "/#{key.to_s}"
            else
              default << "/#{key.to_s}/#{value}"
            end
          end
        end
        default
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
      yield self if block_given?
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

    def destory
      path = "#{@resource_name}s/#{@id}.#{format.extension}"
      connection.delete(path)
    end

    protected
      def connection
        self.class.connection
      end

      def element_path(prefix_options={}, query_options={})
        self.class.element_path(@id, prefix_options, query_options)
      end

      def collection_path(prefix_options={}, query_options={})
        self.class.element_path(prefix_options, query_options)
      end
  end
end
