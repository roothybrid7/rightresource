module RightResource
  class Base
    @@non_rs_params = [:cloud_id,]  # Non RightScale parameters(ex. ec2 api request parameters)

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
      def status_code
        connection.status_code || nil
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
      rescue => e
        logger.error("#{e.class}: #{e.pretty_inspect}")
        logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
        nil
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
        result = format.decode(connection.get(path || [])).map do |resource|
          correct_attributes(resource)
          resource
        end
        instantiate_collection(result)
      rescue => e
        logger.error("#{e.class}: #{e.pretty_inspect}")
        logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
        []
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
        result = format.decode(connection.get(path)).tap do |resource|
          correct_attributes(resource)
          resource[:id] = resource[:href].match(/[0-9]+$/).to_s.to_i
          resource
        end
        instantiate_record(result)
      rescue => e
        logger.error("#{e.class}: #{e.pretty_inspect}")
        logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
        nil
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
      #     :ec2_image_href => "https://my.rightscale.com/api/acct/###/multi_cloud_images/40840", # AMI image or MultiCloud image
      #     :nickname =>"dev703", # Instance rightscale nickname
      #     :instance_type => 'm1.xlarge',
      #     :assoicate_eip_at_launch => '0',
      #     :deployment_href => "https://my.rightscale.com/api/acct/###/deployments/63387",
      #     :ec2_availability_zone=>"ap-southeast-1b",  # (ex: 'us-east-1a', 'any')
      #     :ec2_ssh_key_href => "https://my.rightscale.com/api/acct/###/ec2_ssh_keys/240662",
      #     :ec2_security_group =>
      #       ["https://my.rightscale.com/api/acct/###/ec2_security_groups/170342",
      #       "https://my.rightscale.com/api/acct/###/ec2_security_groups/170344",
      #       "https://my.rightscale.com/api/acct/###/ec2_security_groups/170353"],
      #     :server_template_href => "https://my.rightscale.com/api/acct/###/ec2_server_templates/82665"  # rightscale servertemplate
      #   }
      #   server_id = Server.create(params).id
      #   settings = Server.settings(server_id)
      #   p settings
      #
      def create(params={})
        self.new(params).tap do |resource|
          resource.save
        end
      end

      # Update resource
#      def update(id, params={})
#        #TODO: refactor
#        path = element_path(id)
#        connection.put(path, params)
#      end

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

      # Correct attributes(Correct hash keys recursively)
      # '-'(dash) is included but not '_'(under score) in AWS Parameter keys.
      # On the other hand '_'(under score) is included in RightScale Parameter keys
      # e.g. Hash["ip-address"] -> Hash[:ip_address], Hash["deployment_href"] -> Hash[:deployment_href]
      def correct_attributes(attributes)
        return unless attributes.is_a?(Hash)

        attributes.alter_keys
        attributes.each do |key,value|  # recursive
          attributes[key] =
            case value
            when Array
              value.map do |attrs|
                if attrs.is_a?(Hash)
                  correct_attributes(attrs)
                else
                  attrs.dup rescue attrs
                end
              end
            when Hash
              correct_attributes(value)
            else
              value.dup rescue value
            end
        end
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

    attr_accessor :id, :attributes

    # If no schema has been defined for the class (see
    # <tt>ActiveResource::schema=</tt>), the default automatic schema is
    # generated from the current instance's attributes
    def schema
    #  self.class.schema || self.attributes
    end

    # This is a list of known attributes for this resource. Either
    # gathered from the provided <tt>schema</tt>, or from the attributes
    # set on this instance after it has been fetched from the remote system.
    def known_attributes
    #  self.class.known_attributes + self.attributes.keys.map(&:to_s)
    end

    # Duplicate resource
    def dup
      self.class.new.tap do |resource|
        resource.attributes = @attributes.reject {|key,value| key == :href}
        resource.load_accessor(resource.attributes)
      end
    end

    def initialize(attributes={})
      # sub-resource4json's key name contains '-'
      @attributes = {}
      load_attributes(attributes)
      if @attributes
        if self.class.resource_id && self.class.status_code == 201
          @id = self.class.resource_id
        else
          @id = @attributes[:href].match(/\d+$/).to_s if @attributes[:href]
        end
        load_accessor(@attributes)
      end
      yield self if block_given?
    end

    def load_attributes(attributes)
      raise ArgumentError, "expected an attributes Hash, got #{attributes.pretty_inspect}" unless attributes.is_a?(Hash)
      @attributes = self.class.correct_attributes(attributes)
      self
    end

    def update_attributes(attributes)
      load_attributes(attributes) && load_accessor(attributes) && save
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

    # For checking <tt>respond_to?</tt> without searching the attributes (which is faster).
    alias_method :respond_to_without_attributes?, :respond_to?

    # A method to determine if an object responds to a message (e.g., a method call). In Active Resource, a Person object with a
    # +name+ attribute can answer <tt>true</tt> to <tt>my_person.respond_to?(:name)</tt>, <tt>my_person.respond_to?(:name=)</tt>, and
    # <tt>my_person.respond_to?(:name?)</tt>.
    def respond_to?(method, include_priv = false)
      method_name = method.to_s
      if attributes.nil?
        super
#      elsif known_attributes.include?(method_name)
#        true
      elsif method_name =~ /(?:=|\?)$/ && attributes.include?($`)
        true
      else
        # super must be called at the end of the method, because the inherited respond_to?
        # would return true for generated readers, even if the attribute wasn't present
        super
      end
    end

    protected
      def connection
        self.class.connection
      end

      def update
        attrs = self.attributes.reject {|key,value| @@non_rs_params.include?(key.to_sym) || value.nil?}
        pair = URI.decode({resource_name.to_sym => attrs}.to_params).split('&').map {|l| l.split('=')}
        h = Hash[*pair.flatten]
        @@non_rs_params.each {|key| h[key.to_s] = self.attributes[key] if self.attributes.has_key?(key) && self.attributes[key]}
        connection.put(element_path, h)
      end

      def create
        attrs = self.attributes.reject {|key,value| @@non_rs_params.include?(key.to_sym) || value.nil?}
        pair = URI.decode({resource_name.to_sym => attrs}.to_params).split('&').map {|l| l.split('=')}
        h= Hash[*pair.flatten]
        @@non_rs_params.each {|key| h[key.to_s] = self.attributes[key] if self.attributes.has_key?(key) && self.attributes[key]}
        connection.post(collection_path, h)
        self.id = self.class.resource_id
        self.href = self.class.headers[:location]
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

    private
      def method_missing(method_symbol, *arguments) #:nodoc:
        method_name = method_symbol.to_s

        if method_name =~ /(=|\?)$/
          case $1
          when "="
            attributes[$`.to_sym] = arguments.first
          when "?"
            attributes[$`.to_sym]
          end
        else
          return attributes[method_symbol] if attributes.include?(method_symbol)
          # not set right now but we know about it
#          return nil if known_attributes.include?(method_name)
          super
        end
      end
  end
end
