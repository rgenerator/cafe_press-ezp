module CafePress
  module EZP
    module Event
      class Response
        HEADERS = { 'Content-Type' => 'application/xml' }

        XML_TEMPLATE = '<?xml version="1.0" encoding="UTF-8"?><OrderEventNotificationReceived Result="%s"/>'.freeze
        SUCCESS = sprintf(XML_TEMPLATE, 'Success').freeze
        FAILURE = sprintf(XML_TEMPLATE, 'Failure').freeze

        def initialize(status)
          @body = (status.to_i == 0 ? FAILURE : SUCCESS).dup
          @headers = HEADERS.merge('Content-Length' => @body.size)
        end

        def headers
          @headers
        end

        def to_rack
          [200, @headers, [@body]]
        end

        def to_s
          @body
        end

        alias :to_str :to_s
        alias :inspect :to_s
      end
    end
  end
end
