#!/usr/bin/env ruby

require 'rubygems'
require 'yaml'
require 'json/pure'

$LOAD_PATH << File::expand_path(File::dirname(__FILE__) + "/../")
p $LOAD_PATH

require "lib/right_connection.rb"
require "lib/right_base.rb"

puts "BEGIN OF SCRIPT"
auth_data = open(File::expand_path(File::dirname(__FILE__)) + "/api_auth.yml") {|f| YAML.load(f)}
# convert key.type: String2Symbol
#$login_params = {}
#auth_data.each_pair {|key,value| $login_params[key.to_sym] = value}
#p $login_params.inspect

#Server.user = auth_data["username"]
#Server.password = auth_data["password"]
#Server.account = auth_data["account"]
Server.set_auth(auth_data["username"], auth_data["password"], auth_data["account"])
servers = Server.index
p servers.size
servers = nil
servers = Server.index
p servers.size
servers = nil
servers = Server.index
p servers.size
exit 0

# Entry point
3.times do
  servers = nil
  servers = Server.index
  p servers.size
  servers.each_with_index do |s,i|
  p "BEGIN No: #{i}, Id: #{s.href.match(/\d+$/)} Nickname: #{s.nickname} -----"
    puts "State: #{s.state}"
    p s.attributes
  p "--------------------- END"
  end
end

puts "END OF SCRIPT"
exit 0