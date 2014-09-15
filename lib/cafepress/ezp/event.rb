require 'cafepress/ezp'
require 'cafepress/ezp/event/notification'
require 'cafepress/ezp/event/response'

module CafePress
  module EZP
    module Event
      EventError = Class.new(EZPError)

      Order = Struct.new(:id, :reference_number)
      Item = Struct.new(:id, :sku, :partner_sku, :quantity)

      # TODO: add date_time as a attr?
      class SuccessEvent
        attr_accessor :order, :data, :items

        def initialize(order)
          @items = []
          @order = Order.new(order.attributes['Id'], order.attributes['EZPReferenceNumber'])
          @data = { date_time: order.elements.first.attributes['DateTime'] }

          build_event(order.elements)
        end

        protected

        def build_event(elements)
          # nothing
        end

        def item(element)
          Item.new(*attributes(element).values_at(:id, :sku, :partner_sku, :quantity))
        end

        def attributes(element)
          element.attributes.each_with_object({}) do |(name, value), hash|
            hash[ keyify(name) ] = value
            hash
          end
        end

        def keyify(s)
          s.gsub(/([a-z0-9])([A-Z])/) { "#{$1}_#{$2}" }.downcase.to_sym
        end
      end

      Accepted = Class.new(SuccessEvent)
      AssetsCollected = Class.new(SuccessEvent)
      Complete = Class.new(SuccessEvent)
      InProduction = Class.new(SuccessEvent)

      class Shipment < SuccessEvent
        protected

        def build_event(elements)
          data.merge!(attributes(elements.first))
          items.replace(
            elements.first.elements.map { |i| item(i) }
          )
        end
      end

      class Failed
        attr_accessor :order, :data, :items

        def initialize(doc)
          @items = []  # for compatibility with other events
          @order = Order.new(doc.get_text('ordernumber'), doc.get_text('referencenumber'))
          @data = { message: doc.get_text('message'), affiliate_id: doc.attributes['AffiliateID'] }
        end
      end
    end
  end
end
