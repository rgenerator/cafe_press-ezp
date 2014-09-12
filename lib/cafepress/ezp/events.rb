require 'rexml/document'

module CafePress
  module EZP
    module Event
      # Move Client::Error to EZP::Error?
      # EventError = Class.new(Error)

      def self.parse(request)
        begin
          doc = REXML::Document.new(request)
        rescue REXML::ParseException => e
          raise EventError, "response contains invalid XML: #{e}"
        end

        name = doc.get_elements('/OrderEventNotification/Order/*[1]').first
        raise EventError, "cannot extract event from XML #{request}" if name.nil?
        # raise UnknownEventError, "unknown event: #{name}" unless class.const_defined?(name)
        # self.class.const_get(name).new(...)
      end
    end
  end
end
