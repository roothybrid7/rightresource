require 'uri'
require 'rexml/document'

begin
  require 'rubygems'
  require 'json/pure'
  require 'rest_client'
  require 'crack'
rescue LoadError => e
  STDERR::puts e.message
end

$:.unshift(File.dirname(__FILE__))
require 'right_resource/connection'
require 'right_resource/base'
require 'right_resource/deployment'
require 'right_resource/server'
require 'right_resource/server_array'
require 'right_resource/formats'

module RightResource
  API_VERSION = "1.0"
end
