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
$login_params = {}
auth_data.each_pair {|key,value| $login_params[key.to_sym] = value}
p $login_params.inspect

# Entry point
begin
  3.times do
    server = Server.show("838755")
    p server
    #p server.attributes['nickname']
    p server.attributes[:nickname]
    p server.nickname
    #servers.each do |s|
    #p "BEGIN Id: #{s.href.match(/\d+$/)} Nickname: #{s.nickname} -----"
    #  puts "State: #{s.state}"
    #  p s.attributes
    #p "--------------------- END"
    #end
  end
rescue => e
  STDERR.puts e.message
end

puts "END OF SCRIPT"
exit 0
