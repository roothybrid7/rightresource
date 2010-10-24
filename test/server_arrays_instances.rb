#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json/pure'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")

require "lib/right_resource.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}

ServerArray.set_auth(auth_data["username"], auth_data["password"], auth_data["account"])
server_array = ServerArray.show("9454")
server_array.instances
p server_array.attributes
puts "############ INSTANCE_VARIABLES"
p server_array.instance_variables.each {|v| puts "ins_var: " + v}
puts "############ PUBLIC METHODS"
p server_array.public_methods.each {|m| puts "pub_method: " + m}
#server_array.attributes[:instances].each do |ins|
server_array.active_instances.each do |ins|
p ins
end
#p server_array.i_a2d4d3f0[:ip_address]
#instances = ServerArray.instances("9454")
#p instances.size
#p server_array.instances
#ServerArray.instances("9454")
#server_arrays = ServerArray.index
#p ServerArray.headers
#instances.each do |ins|
#  p ins.attributes
#  puts "############ INSTANCE_VARIABLES"
#  p ins.instance_variables.each {|v| puts "ins_var: " + v}
#  puts "############ PUBLIC METHODS"
#  p ins.public_methods.each {|m| puts "pub_method: " + m}
#  puts "Get info by attributes hash key: "
#  p "BEGIN Id: #{ins.id} Nickname: #{ins.attributes[:nickname]} -----"
#  puts "State: " + ins.attributes[:state].to_s
#  puts "Get info by method: "
#  p "BEGIN Id: #{ins.id} Nickname: #{ins.nickname} -----"
#  puts "Active?: " + ins.state.to_s
#  p "--------------------- END"
#  puts "GGGOOOOOOOOOOOOOOOOOOOOOOOD!!!!!L"
#end
puts "END OF SCRIPT"
exit 0
