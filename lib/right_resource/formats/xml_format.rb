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

      def decode(xml)
        Crack::XML.parse(xml)
      end
    end
  end
end

