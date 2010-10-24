require 'rubygems'
require 'rest_client'
require 'uri'
require 'rexml/document'
require 'json/pure'

$:.unshift(File.dirname(__FILE__))
require 'right_resource/connection'
require 'right_resource/base'
require 'right_resource/deployment'
require 'right_resource/server'
require 'right_resource/server_array'
require 'right_resource/formats'

module RightResource
  VERSION = "0.1.0"
  API_VERSION = "1.0"
end
