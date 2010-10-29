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
require 'right_resource/formats'
# Login API
require 'right_resource/login'
# Management API
require 'right_resource/deployment'
require 'right_resource/server'
require 'right_resource/ec2_ebs_volume'
require 'right_resource/ec2_elastic_ip'
require 'right_resource/ec2_security_group'
require 'right_resource/ec2_ssh_key'
require 'right_resource/server_array'
require 'right_resource/ec2_ebs_snapshot'
require 'right_resource/s3_bucket'
#require 'right_resource/tag'
# Design API
require 'right_resource/server_template'
require 'right_resource/right_script'
require 'right_resource/multi_cloud_image'
require 'right_resource/macro'
require 'right_resource/credential'

module RightResource
  API_VERSION = "1.0"
end
