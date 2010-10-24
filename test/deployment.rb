#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json/pure'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")

require "lib/right_resource.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}

Deployment.set_auth(auth_data["username"], auth_data["password"], auth_data["account"])
deployment = Deployment.show("61338")
#deployments = Deployment.index
#p Deployment.headers
p deployment.headers
p deployment.attributes
p deployment.servers
#deployments.each do |deployment|
#  p deployment.attributes
#  puts "############ INSTANCE_VARIABLES"
#  p deployment.instance_variables.each {|v| puts "ins_var: " + v}
#  puts "############ PUBLIC METHODS"
#  p deployment.public_methods.each {|m| puts "pub_method: " + m}
#  puts "Get info by attributes hash key: "
#  p "BEGIN Id: #{deployment.id} Nickname: #{deployment.attributes[:nickname]} -----"
#  puts "Servers: #{deployment.attributes[:servers]}"
#  puts "Get info by method: "
#  p "BEGIN Id: #{deployment.id} Nickname: #{deployment.nickname} -----"
#  puts "Servers: #{deployment.servers}"
#  p "--------------------- END"
#  puts "GGGOOOOOOOOOOOOOOOOOOOOOOOD!!!!!L"
#end
puts "END OF SCRIPT"
exit 0
