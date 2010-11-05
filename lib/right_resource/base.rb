module RightResource
  class Base
    class << self
      def connection=(conn)
        @connection = conn
      end

      def connection
        if defined?(@connection) || superclass == Object
          raise ArgumentError, "Not set connection object!!" unless @connection
          @connection.clear
          @connection
        else
          superclass.connection
        end
      end

      def format
        @connection.format || RightResource::Formats::JsonFormat
      end
      def headers
        @connection.headers || {}
      end

      def resource_id
        @connection.resource_id || nil
      end

      # examples:
      # Server.index(:filter => "nickname=testserver")
      # Deployment.index(:filter => "nickname=staging")
      # ServerArray.index()
      def index(params={})
        path = "#{resource_name}s.#{format.extension}#{query_string(params)}"
        instantiate_collection(format.decode(connection.get(path || [])))
      end

      # examples:
      # server_id = 1
      # Server.show(server_id)
      #
      # Deployment.show(1, :server_settings => "true")
      # ServerArray.show(1)
      def show(id, prefix={}, params={})
        path = element_path(id, prefix, params)
        instantiate_record(format.decode(connection.get(path)))
      end

      # examples:
      # params = {:nickname => "dev", :deployment => "dev test", :default_ec2_availability_zone => "ap-northeast-1a"}
      def create(params={})
        #TODO: refactor
        self.new(params).tap do |resource|
          resource.save
        end
#        path = collection_path
#        connection.post(path, params)
      end

      def update(id, params={})
        #TODO: refactor
        path = element_path(id)
        connection.put(path, params)
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
        if @resource_id.nil?
          @id = attrs[:href].match(/\d+$/).to_s if attrs[:href]
        else
          @id = @resource_id
        end
        load_accessor(attrs)
      end
      yield self if block_given?
    end
    attr_accessor :id
    attr_reader :attributes, :resource_name, :headers, :resource_id

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

    def new?
      id.nil?
    end
    alias :new_record? :new?

    def save
      new? ? create : update
    end

    def destory
      connection.delete(element_path)
    end

    protected
      def connection
        self.class.connection
      end

      def update
        attrs = self.attributes
        connection.put(element_path(prefix_options), encode, self.class.headers).tap do |response|
          load_attributes_from_response(response)
        end
      end

      def create
        headers = self.class.headers.each_pair do |key, value|
        end
        connection.post(collection_path, self.class.headers).tap do |response|
          self.id = id_from_response(response)
          load_attributes_from_response(response)
        end
      end

      def element_path(prefix_options={}, query_options={})
        self.class.element_path(@id, prefix_options, query_options)
      end

      def collection_path(prefix_options={}, query_options={})
        self.class.element_path(prefix_options, query_options)
      end
  end
end
