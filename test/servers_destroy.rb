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
c2 = RightResource::Connection.new(:format => "js")
p c2.inspect
c1.login(login_params)
c2.login(login_params)
p c2.inspect
#res = c2.put("servers")
#puts res
puts "delete RightScale API info: for xml(Default)"
res = c1.delete("servers/838359")
puts res
p c1.headers
p c1.resource_id
exit 0

puts "END OF SCRIPT"
