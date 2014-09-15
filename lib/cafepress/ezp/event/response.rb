module CafePress
  module EZP
    module Event
      class Response
        HEADERS = { 'Content-Type' => 'application/xml' }.freeze
        BODY = '<?xml version="1.0" encoding="UTF-8"?><OrderEventNotificationReceived Result="%s"/>'.freeze        

        def initialize(status)          
          @body = sprintf BODY, status.to_i == 0 ? 'Failure' : 'Success'
        end

        def headers          
          HEADERS
        end

        def to_rack
          # TODO: content length
          [200, HEADERS, [@body]]
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
