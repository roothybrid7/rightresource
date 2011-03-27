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
        Crack::JSON.parse(json)
      end
    end
  end
end

