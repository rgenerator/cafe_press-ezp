require 'rexml/document'

module CafePress
  module EZP
    module Event

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

          if doc.root.name == 'orderfailed'
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
              name = order.elements.first.name
              raise EventError, "unknown event: #{name}" unless Event.const_defined?(name)

              events << Event.const_get(name).new(order)
            end

            new(id, events)
          end

          def order_failed_event(doc)
            new(nil, [ Failed.new(doc) ])
          end
        end
      end
    end
  end
end

