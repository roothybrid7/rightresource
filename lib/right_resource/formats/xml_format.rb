#!/usr/bin/env ruby
# Author:: Satoshi Ohki <roothybrid7@gmail.com>

require 'crack/xml'

module RightResource
  module Formats
    module XmlFormat
      extend self

      def extension
        "xml"
      end

      def mime_type
        "application/xml"
      end

      def encode(hash)
        raise NotImplementedError, "Not Implementated function #{self.class.name}::#{__method__.to_s}"
      end

      def decode(json)
        Crack::XML.parse(json)
      end
    end
  end
end

