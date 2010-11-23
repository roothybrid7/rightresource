module RightResource
  class Connection
    attr_accessor :api_version, :log, :url, :api, :format, :username, :password, :account, :logger
    attr_reader :headers, :resource_id, :response, :status_code, :timeout, :open_timeout

    # Set RestFul Client Parameters
    def initialize(params={})
      @api_version = API_VERSION
      @url = params[:url] || "https://my.rightscale.com"
      @api = "#{@url}/api/acct/"
      @format = params[:format] || RightResource::Formats::JsonFormat
      @logger = params[:logger] || Logger.new(STDERR).tap {|l| l.level = Logger::WARN}
      RestClient.log = STDERR if @logger.level == Logger::DEBUG # HTTP request/response log
      yield self if block_given?  # RightResource::Connection.new {|conn| ...}
    end

    # RestClient authentication
    # === Examples
    #   params = {:username => "foo", :password => "bar", :account => "1"}
    #   conn = Connection.new
    #   conn.login(params)
    def login(params={})
      @username = params[:username] if params[:username]
      @password = params[:password] if params[:password]
      @account = params[:account] if params[:account]
      @open_timeout = params[:open_timeout] || 10 # Connection.timeout
      @timeout = params[:timeout] || 60           # Response.read.timeout
      req_opts = {:user => @username, :password => @password, :open_timeout => @open_timeout, :timeout => @timeout}
      @api_object = RestClient::Resource.new("#{@api}#{@account}", req_opts)
    rescue => e
      @logger.error("#{e.class}: #{e.pretty_inspect}")
      @logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
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
      @response = @api_object[path].__send__(method.to_sym, api_version.merge(headers))
      @status_code = @response.code
      @headers = @response.headers
      @resource_id = @headers[:location].match(/\d+$/).to_s unless @headers[:location].nil?
      @response.body
    rescue Timeout::Error => e
      raise TimeoutError.new(e.message)
    rescue => e
      @status_code = e.http_code
      @logger.error("#{e.class}: #{e.pretty_inspect}")
      @logger.debug {"Backtrace:\n#{e.backtrace.pretty_inspect}"}
    ensure
      @logger.debug {"#{__FILE__} #{__LINE__}: #{self.class}\n#{self.pretty_inspect}\n"}
    end

    # Resource clear
    def clear
      @response = @headers = @resource_id = @status_code = nil
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
      self.request(path, "put", headers)
    end

    # destory
    def delete(path, headers={})
      self.request(path, "delete", headers)
    end
  end
end
