require 'rexml/document'
require 'cafepress/ezp/events'

module CafePress
  module EZP
    module Events

      class Notification
        attr_accessor :id, :events

        def initialize(id, events)
          @id = id
          @events = events
        end

        def failure?
          events.all? { |e| e.is_a?(Failed) }
        end

        def self.parse(input)
          begin
            doc = REXML::Document.new(input)
          rescue REXML::ParseException => e
            invalid_xml(input)
          end

          invalid_xml(input) unless doc.root

          if doc.root.name == "orderfailed"
            order_failed_event(doc.root)
          else
            order_state_event(doc.root)
          end
        end

        private

        class << self
          def invalid_xml(xml)
            raise EventError, "response contains invalid XML: #{xml}"
          end

          def order_state_event(doc)
            id = doc.attributes['Id']
            events = []

            orders = doc.get_elements('/OrderEventNotification/Order')
            orders.each do |order|
              name = order.children[0].name
              raise UnknownEventError, "unknown event: #{name}" unless self.class.const_defined?(name)

              events << self.class.const_get(name).new(id, order)
            end

            new(id, events)
          end

          def order_failed_event(doc)
            new(nil, [ OrderFailed.new(doc) ])
          end
        end
      end
    end
  end
end

