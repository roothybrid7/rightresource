#!/usr/bin/env ruby
# Author:: Satoshi Ohki <roothybrid7@gmail.com>

require 'json/pure'

module RightResource
  module Formats
    module JsonFormat
      extend self

      def extension
        "js"
      end

      def mime_type
        "application/json"
      end

      def encode(hash)
        JSON.generate(hash)
      end

      def decode(json)
        JSON.parse(json)
      end
    end
  end
end

