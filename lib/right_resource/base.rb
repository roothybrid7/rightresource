module RightResource
  class Base
    class << self # Define singleton methods
      # Set Logger object
      # === Examples
      #   logger = Logger.new(STDERR)
      #   logger.level = Logger::WARN [Default: Logger::DEBUG]
      #   Server.logger = logger
      def logger=(logger)
        @logger = logger
      end

      def logger
        @logger ||= Logger.new(STDERR)
      end

      # Set RESTFul client with login authentication for HTTP Methods(Low level)
      # === Examples
      #   conn = Connection.new do |c|
      #     c.login(:username => "user", :password => "pass", :account => "1")
      #   end
      #   Server.connection = conn
      def connection=(conn)
        @connection = conn
      end

      # Get RESTFul client for HTTP Methods(Low level)
      # and use in resource api call
      # === Examples
      #   conn = Server.connection
      #   conn.get("servers?filter=nickname=server1")
      #
      # ex. resource api call:
      #   Server.index
      def connection
        if defined?(@connection) || superclass == Object
          raise ArgumentError, "Not set connection object!!" unless @connection
          @connection
        else
          superclass.connection
        end
      end

      # Get request and response format type object
      def format
        connection.format || RightResource::Formats::JsonFormat
      end

      # Get response headers via RESTFul client
      def headers
        connection.headers || {}
      end

      # Get response status code
      def status
        connection.status || nil
      end

      # Get resource id in response location header via RESTFul client(create only?)
      def resource_id
        connection.resource_id || nil
      end

      # Get resources by index method
      # same resources support criteria like filtering.
      #
      # === Params
      # params:: criteria[ex. :filter => "nickname=hoge"](Hash)
      # === Return
      # Resource list(Array)
      #
      # === Examples
      #   dep = Deployment.index(:filter => ["nickname=payment-dev", "nickname=payment-staging"])
      #
      #   test = Server.index(:filter => "nickname<>test")
      #
      # Criteria unsupport
      #     array = ServerArray.index
      #
      # Get first 5 resources
      #     server = Server.index.first(5) # see Array class
      # Get last resource
      #     server = Server.index.last # see Array class
      #
      # Get all operational server's nickname
      #     Server.index.each do |server|
      #       puts server.nickname if server.state = "operational"
      #     end
      #
      # Get EC2 Security Groups(aws ap = 4)
      #   sec_grps = Ec2SecurityGroup.index(:cloud_id => "4")
      def index(params = {})
        path = "#{resource_name}s.#{format.extension}#{query_string(params)}"
        connection.clear
        instantiate_collection(format.decode(connection.get(path || [])))
      rescue RestClient::ResourceNotFound
        nil
      rescue => e
        logger.error("#{e.class}: #{e.pretty_inspect}")
        logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
      ensure
        logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
      end

      # Get resource
      # === Params
      # params:: Query Strings(Hash)
      # === Return
      # Resource(Object)
      #
      # === Example
      #   server_id = 1
      #   Server.show(server_id) #=> #<Server:0x1234...>
      #
      # Get deployment resource with server's subresource
      #     Deployment.show(1, :params => {:server_settings => "true"}) #=> #<Deployment:0x12314...>
      def show(id, params = {})
        path = element_path(id, nil, params)
        connection.clear
        instantiate_record(format.decode(connection.get(path)))
      rescue RestClient::ResourceNotFound
        nil
      rescue => e
        logger.error("#{e.class}: #{e.pretty_inspect}")
        logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
      ensure
        logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
      end

      # Create new resource
      # Example:
      #   params = {
      #     :nickname => "dev",
      #     :deployment_href => "https://my.rightscale.com/api/acct/22329/deployments/59855",
      #     :server_template_href => "https://my.rightscale.com/api/acct/22329/server_templates/76610",
      #     :ec2_availability_zone => "ap-northeast-1a"
      #   }
      #   Server.create(params)
      def create(params={})
        #TODO: refactor
        self.new(params).tap do |resource|
          resource.save
        end
#        path = collection_path
#        connection.post(path, params)
      end

      # Update resource
      def update(id, params={})
        #TODO: refactor
        path = element_path(id)
        connection.put(path, params)
      end

      # Delete resource
      # Example:
      #   Server.destory(1)
      #
      #   server = Server.index(:filter => "aws_id=i-012345")
      #   Server.destory(server.id)
      def destory(id)
        path = element_path(id)
        connection.delete(path)
      end

      # Get single resource
      def element_path(id, prefix_options = nil, query_options = nil)
        "#{resource_name}s/#{id}#{prefix(prefix_options)}.#{format.extension}#{query_string(query_options)}"
      end

      # Get resource collections
      def collection_path(prefix_options = nil, query_options = nil)
        "#{resource_name}s#{prefix(prefix_options)}.#{format.extension}#{query_string(query_options)}"
      end

      # Get resource name(equals plural of classname)
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

      def generate_attributes(attributes)
        raise ArgumentError, "expected an attributes Hash, got #{attributes.pretty_inspect}" unless attributes.is_a?(Hash)
        attrs = {}
        attributes.each_pair {|key,value| attrs[key.to_s.gsub('-', '_').to_sym] = value}
        attrs
      end

      protected
        def prefix(options = nil)
          default = ""
          unless options.nil?
            if options.is_a?(String) || options.is_a?(Symbol)
              default = "/#{options}"
            elsif options.is_a?(Hash)
                  options.each_pair do |key,value|
                    if value.nil? || value.empty?
                      default << "/#{key}"
                    else
                      default << "/#{key}/#{value}"
                    end
                  end
            else
              raise ArgumentError, "expected an Hash, String or Symbol, got #{options.pretty_inspect}"
            end
          end
          default
        end

        # create querystring by crack to_params method
        def query_string(options = {})
          !options.is_a?(Hash) || options.empty? ? "" : '?' + options.to_params
        end

        # Get resource collection
        def instantiate_collection(collection)
          collection.collect! {|record| instantiate_record(record)}
        end

        # Get a resource and create object
        def instantiate_record(record)
          self.new(record)
        end
    end

    def initialize(attributes={})
      # sub-resource4json's key name contains '-'
#      attrs = generate_attributes(attributes)
      @attributes = {}
      loads(attributes)
      if @attributes
        if self.class.resource_id.nil?
          @id = @attributes[:href].match(/\d+$/).to_s if @attributes[:href]
        else
          @id = self.class.resource_id
        end
        load_accessor(@attributes)
      end
      yield self if block_given?
    end
    attr_accessor :id, :attributes

    def loads(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.pretty_inspect}" unless attributes.is_a?(Hash)
      attributes.each_pair {|key,value| @attributes[key.to_s.gsub('-', '_').to_sym] = value}
      self
    end

    def update_attributes(attributes)
      loads(attributes) && load_accessor(attributes) && save
    end

    def load_accessor(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.pretty_inspect}" unless attributes.is_a?(Hash)
      attributes.each_pair do |key, value|
        instance_variable_set("@#{key}", value) # Initialize instance variables
        self.class.class_eval do
          define_method("#{key}=") do |new_value| # ex. obj.key = new_value
            instance_variable_set("@#{key}", new_value)
          end
          define_method(key) do
            instance_variable_get("@#{key}")
          end
        end
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
        #TODO: refactor hard coding
        attrs = self.attributes.reject {|key,value| key.to_s == "cloud_id"}
        pair = URI.decode({resource_name.to_sym => attrs}.to_params).split('&').map {|l| l.split('=')}
        headers = Hash[*pair.flatten]
        headers["cloud_id"] = self.attributes[:cloud_id] if self.attributes.has_key?(:cloud_id)
        connection.put(element_path, headers)
      end

      def create
        #TODO: refactor hard coding
        attrs = self.attributes.reject {|key,value| key.to_s == "cloud_id"}
        pair = URI.decode({resource_name.to_sym => attrs}.to_params).split('&').map {|l| l.split('=')}
        headers = Hash[*pair.flatten]
        headers["cloud_id"] = self.attributes[:cloud_id] if self.attributes.has_key?(:cloud_id)
        connection.post(collection_path, headers)
        self.id = self.class.resource_id
      end

      def resource_name
        self.class.resource_name
      end

      def element_path(prefix_options=nil, query_options=nil)
        self.class.element_path(self.id, prefix_options, query_options)
      end

      def collection_path(prefix_options=nil, query_options=nil)
        self.class.collection_path(prefix_options, query_options)
      end
  end
end
