#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json/pure'
require 'crack'
require 'rexml/document'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")

require "lib/right_resource.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}

ServerArray.set_auth(auth_data["username"], auth_data["password"], auth_data["account"])
#server_array = ServerArray.show("9454")
server_array = ServerArray.show("8644")
server_array.instances
#server_arrays = ServerArray.index
#p ServerArray.headers
p server_array.headers
puts server_array.attributes
puts "#######"
p server_array.nickname
p server_array.active
p server_array.active_instances_count
#server_arrays.each do |server_array|
#  p server_array.attributes
#  puts "############ INSTANCE_VARIABLES"
#  p server_array.instance_variables.each {|v| puts "ins_var: " + v}
#  puts "############ PUBLIC METHODS"
#  p server_array.public_methods.each {|m| puts "pub_method: " + m}
#  puts "Get info by attributes hash key: "
#  p "BEGIN Id: #{server_array.id} Nickname: #{server_array.attributes[:nickname]} -----"
#  puts "Active?: " + server_array.attributes[:active].to_s
#  puts "Active instances: " + server_array.attributes[:active_instances_count].to_s
#  puts "Get info by method: "
#  p "BEGIN Id: #{server_array.id} Nickname: #{server_array.nickname} -----"
#  puts "Active?: " + server_array.active.to_s
#  puts "Active instances: " + server_array.active_instances_count.to_s
#  p "--------------------- END"
#  puts "GGGOOOOOOOOOOOOOOOOOOOOOOOD!!!!!L"
#end
puts "END OF SCRIPT"
exit 0
