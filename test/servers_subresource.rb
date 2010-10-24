#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json/pure'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")

require "lib/right_resource.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}

Server.set_auth(auth_data["username"], auth_data["password"], auth_data["account"])
server = Server.show("837536")
server.settings
p server.headers
p server.resource_id
#p Server.headers
#p Server.resource_id
puts "############ INSTANCE_VARIABLES"
#p server.instance_variables.each {|v| puts "ins_var: " + v}
puts "############ PUBLIC METHODS"
#p server.public_methods.each {|m| puts "pub_method: " + m}
# Entry point
puts "Get info by attributes hash key: "
p "BEGIN Id: #{server.attributes[:href].match(/\d+$/)} Nickname: #{server.attributes[:nickname]} -----"
puts "State: #{server.attributes[:state]}"
puts "Get info by method: "
p "BEGIN Id: #{server.href.match(/\d+$/)} Nickname: #{server.nickname} -----"
puts "State: #{server.state}"
#  p s.attributes
p "--------------------- END"
puts "GGGOOOOOOOOOOOOOOOOOOOOOOOD!!!!!L"

puts "END OF SCRIPT"
exit 0
