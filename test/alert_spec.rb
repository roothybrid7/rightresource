#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json/pure'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")
p $LOAD_PATH

require "lib/right_resource.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}
AlertSpec.set_auth(auth_data["username"], auth_data["password"], auth_data["account"])
alert_specs = AlertSpec.index
p alert_specs.attributes

puts "END OF SCRIPT"
exit 0
