# Author:: Satoshi Ohki <roothybrid7@gmail.com>

require 'rubygems'
require 'rest_client'
require 'uri'
require 'rexml/document'
require 'json/pure'

$:.unshift(File.dirname(__FILE__))
require 'right_resource/connection'
require 'right_resource/base'
require 'right_resource/server'

module RightResource
  VERSION = '1.0'
end
