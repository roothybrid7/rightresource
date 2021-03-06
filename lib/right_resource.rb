require 'resolv-replace'
require 'uri'
require 'rexml/document'
require 'logger'
require 'pp'
require 'rubygems'

gem 'json', '~>1.0'
gem 'rest-client', '~>1.0'
gem 'crack', '~>0.1.0'
require 'json/pure'
require 'rest_client'
require 'crack'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Ruby core extensions
require 'right_resource/core_ext'
# base class
require 'right_resource/connection'
require 'right_resource/base'
require 'right_resource/formats'
# Management API
require 'right_resource/deployment'
#require 'right_resource/status'
require 'right_resource/alert_spec'
require 'right_resource/server'
require 'right_resource/ec2_ebs_volume'
require 'right_resource/ec2_elastic_ip'
require 'right_resource/ec2_security_group'
require 'right_resource/ec2_ssh_key'
require 'right_resource/server_array'
require 'right_resource/ec2_ebs_snapshot'
require 'right_resource/s3_bucket'
require 'right_resource/tag'
# Design API
require 'right_resource/server_template'
require 'right_resource/right_script'
require 'right_resource/multi_cloud_image'
require 'right_resource/macro'
require 'right_resource/credential'

module RightResource
  VERSION = '0.4.5'
  API_VERSION = "1.0"
end
