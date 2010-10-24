#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")
p $LOAD_PATH

require "lib/right_connection.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}
# convert key.type: String2Symbol
login_params = {}
auth_data.each_pair {|key,value| login_params[key.to_sym] = value}
p login_params.inspect
c1 = RightResource::Connection.new
p c1.inspect
c2 = RightResource::Connection.new(format = "js")
p c2.inspect
#c1.login(login_params)
c2.login(login_params)
p c2.inspect
#res = c2.get("servers")
#puts res
puts "Get RightScale API info: for xml(Default)"
res = c1.get("servers?filter=nickname=kff-mixi-db-001")
puts res
p c1.headers
p c1.resource_id
puts "Get RightScale API info: for json"
res = c2.get("servers?filter=nickname=kff-mixi-db-001")
p res
p c2.format
p c2.headers
p c2.resource_id
puts "Get RightScale API info: for xml"
c2.format = "xml"
res = c2.get("servers?filter=nickname=kff-mixi-db-001")
puts res
p c2.headers
p c2.resource_id

puts "END OF SCRIPT"
