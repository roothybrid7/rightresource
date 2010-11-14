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
        if defined?(@logger) || superclass == Object
          @logger ||= Logger.new(STDERR).tap {|l| l.level = Logger::WARN}
        else
          superclass.logger
        end
      end

      # Set RESTFul client with login authentication for HTTP Methods(Low level)
      # === Examples
      #   conn = RightResource::Connection.new do |c|
      #     c.login(:username => "user", :password => "pass", :account => "1")
      #   end
      #   Deployment.connection = conn
      #   Deployment.show(1)  # => GET /api/acct/1/deployments/1.json
      #
      #   RightResource::Base.connction = conn
      #   Ec2EbsVolume.show(1)  # => GET /api/acct/1/ec2_ebs_volumes/1.json
      #   Server.index
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
      #   Server.index # => GET /api/acct/1/servers.json
      def connection
        if defined?(@connection) || superclass == Object
          raise ArgumentError, "Not set connection object!!" unless @connection
          @connection
        else
          superclass.connection
        end
      end

      # Sets the format that attributes are sent and received in from a mime type reference:
      #
      # === Examples
      #   Server.format = RightResource::Formats::JsonFormat
      #   Server.show(1) # => GET /api/acct/1/servers/1.json
      #
      #   RightResource::Base.format = RightResource::Formats::JsonFormat
      #   Server.index # => GET /api/acct/1/servers.json
      #   Ec2EbsVolume.index # => GET /api/acct/1/ec2_ebs_volumes.json
      def format=(mime_type_reference_or_format)
        connection.format = mime_type_reference_or_format
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

      # RestFul Method
      def action(method, path, params={})
        case method
        when :get
          connection.get(path, params)
        when :post
          connection.post(path, params)
        when :put
          connection.put(path, params)
        when :delete
          connection.delete(path, params)
        end
      rescue RestClient::ResourceNotFound
        nil
      rescue => e
        logger.error("#{e.class}: #{e.pretty_inspect}")
        logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
      ensure
        logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
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
      # ==== Parameters
      #
      # * +params+ - see Examples
      #
      # === Examples
      #   params = {
      #     :cloud_id => 4, # {1 = us-east; 2 = eu; 3 = us-west, 4 = ap}
      #     :ec2_image_href => "https://my.rightscale.com/api/acct/22329/multi_cloud_images/40840", # AMI image or MultiCloud image
      #     :nickname =>"dev703", # Instance rightscale nickname
      #     :instance_type => 'm1.xlarge',
      #     :assoicate_eip_at_launch => '0',
      #     :deployment_href => "https://my.rightscale.com/api/acct/22329/deployments/63387",
      #     :ec2_availability_zone=>"ap-southeast-1b",  # (ex: 'us-east-1a', 'any')
      #     :ec2_ssh_key_href => "https://my.rightscale.com/api/acct/22329/ec2_ssh_keys/240662",
      #     :ec2_security_group =>
      #       ["https://my.rightscale.com/api/acct/22329/ec2_security_groups/170342",
      #       "https://my.rightscale.com/api/acct/22329/ec2_security_groups/170344",
      #       "https://my.rightscale.com/api/acct/22329/ec2_security_groups/170353"],
      #     :server_template_href => "https://my.rightscale.com/api/acct/22329/ec2_server_templates/82665"  # rightscale servertemplate
      #   }
      #   server_id = Server.create(params).id
      #   settings = Server.settings(server_id)
      #   p settings
      #
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
        "#{resource_name}s/#{id}#{prefix(prefix_options)}#{query_string(query_options)}"
      end

      # Get resource collections
      def collection_path(prefix_options = nil, query_options = nil)
        "#{resource_name}s#{prefix(prefix_options)}#{query_string(query_options)}"
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
          "#{default}.#{format.extension}"
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
        h = Hash[*pair.flatten]
        h["cloud_id"] = self.attributes[:cloud_id] if self.attributes.has_key?(:cloud_id)
        connection.put(element_path, h)
      end

      def create
        #TODO: refactor hard coding
        attrs = self.attributes.reject {|key,value| key.to_s == "cloud_id"}
        pair = URI.decode({resource_name.to_sym => attrs}.to_params).split('&').map {|l| l.split('=')}
        h= Hash[*pair.flatten]
        h["cloud_id"] = self.attributes[:cloud_id] if self.attributes.has_key?(:cloud_id)
        connection.post(collection_path, h)
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
