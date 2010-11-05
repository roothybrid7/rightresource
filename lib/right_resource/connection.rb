module RightResource
  class Connection
    attr_accessor :api_version, :log, :api, :format, :username, :password, :account, :logger
    attr_reader :headers, :resource_id

    def initialize(format=nil)
      @api_version = API_VERSION
      @api = "https://my.rightscale.com/api/acct/"
      @format = format || RightResource::Formats::JsonFormat
      yield self if block_given?
    end

    def login(params={})
      @username = params[:username] unless params[:username].nil? || params[:username].empty?
      @password = params[:password] unless params[:password].nil? || params[:password].empty?
      @account = params[:account] unless params[:account].nil? || params[:account].empty?

      @api_object = RestClient::Resource.new("#{@api}#{@account}", @username, @password)
    rescue => e
      STDERR.puts e.message
    end

    def login?
      @api_object ? true : false
    end

    def send(path, method="get", headers={})
      raise "Not Login!!" unless self.login?
      if /(.xml|.js)/ =~ path
        path = URI.encode(path)
      elsif /\?(.*)$/ =~ path
        path = URI.encode("#{path}&format=#{@format.extension}")
      else
        path = URI.encode("#{path}?format=#{@format.extension}")
      end
      unless method.match(/(get|put|post|delete)/)
        raise "Invalid Action: get|put|post|delete only"
      end
      api_version = {:x_api_version => @api_version, :api_version => @api_version}

      @response = @api_object[path].send(method.to_sym, api_version.merge(headers))
      @headers = @response.headers ||= {}
      @resource_id = @headers[:location].match(/\d+$/) unless @headers[:location].nil?
      @response.body
    rescue => e
      STDERR.puts e.message
    end

    def clear
      @response = @headers = @resource_id = nil
    end

    # HTTP methods
    # show|index
    def get(path, headers={})
      self.send(path, "get", headers)
    end

    # create
    def post(path, headers={})
      self.send(path, "post", headers)
    end

    # update
    def put(path, headers={})
      self.send(path, "put", headers)
    end

    # destory
    def delete(path, headers={})
      self.send(path, "delete", headers)
    end
  end
end
