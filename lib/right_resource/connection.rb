module RightResource
  class Connection
    @reraise = false

    attr_accessor :api_version, :log, :api, :format, :username, :password, :account, :reraise
    attr_reader :headers, :resource_id, :response, :status

    # Set RestFul Client Parameters
    def initialize(params={})
      @api_version = API_VERSION
      @api = "https://my.rightscale.com/api/acct/"
      @format = params[:format] || RightResource::Formats::JsonFormat
      @logger = params[:logger] || Logger.new(STDERR)
      RestClient.log = STDERR if @logger.level == Logger::DEBUG # HTTP request/response log
      yield self if block_given?  # RightResource::Connection.new {|conn| ...}
    end

    # RestClient authentication
    # === Examples
    #   params = {:username => "foo", :password => "bar", :account => "1"}
    #   conn = Connection.new
    #   conn.login(params)
    def login(params={})
      @username = params[:username] unless params[:username].nil? || params[:username].empty?
      @password = params[:password] unless params[:password].nil? || params[:password].empty?
      @account = params[:account] unless params[:account].nil? || params[:account].empty?
      @api_object = RestClient::Resource.new("#{@api}#{@account}", @username, @password)
    rescue => e
      @logger.error("#{e.class}: #{e.pretty_inspect}")
      @logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
      raise if self.reraise
    ensure
      @logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
    end

    def login?
      @api_object ? true : false
    end

    # Send HTTP Request
    def request(path, method="get", headers={})
      raise "Not Login!!" unless self.login?
#      if /(.xml|.js)/ =~ path
#        path = URI.encode(path)
#      elsif /\?(.*)$/ =~ path
#        path = URI.encode("#{path}&format=#{@format.extension}")
#      else
#        path = URI.encode("#{path}?format=#{@format.extension}")
#      end
      unless method.match(/(get|put|post|delete)/)
        raise "Invalid Action: get|put|post|delete only"
      end
      api_version = {:x_api_version => @api_version, :api_version => @api_version}

      @response = @api_object[path].send(method.to_sym, api_version.merge(headers))
      @status = @response.code
      @headers = @response.headers
      @resource_id = @headers[:location].match(/\d+$/).to_s unless @headers[:location].nil?
      @response.body
    rescue => e
      @status = e.http_code
      @logger.error("#{e.class}: #{e.pretty_inspect}")
      @logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
      raise if self.reraise
    ensure
      @logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
    end

    def clear
      @response = @headers = @resource_id = @status = nil
    ensure
      @logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
    end

    # HTTP methods
    # show|index
    def get(path, headers={})
      self.request(path, "get", headers)
    end

    # create
    def post(path, headers={})
      self.request(path, "post", headers)
    end

    # update
    def put(path, headers={})
puts path.pretty_inspect
puts headers.pretty_inspect
      self.request(path, "put", headers)
    end

    # destory
    def delete(path, headers={})
      self.request(path, "delete", headers)
    end
  end
end
