require 'cafe_press/ezp'
require 'cafe_press/ezp/event/notification'
require 'cafe_press/ezp/event/response'

module CafePress
  module EZP
    module Event
      EventError = Class.new(EZPError)

      Order = Struct.new(:id, :reference_number)
      Item = Struct.new(:id, :sku, :partner_sku, :quantity, :project_id)

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

        # This is okay for all events except Moderation*, which we don't support.
        # If we ever do support then this will have to be placed into another subclass -or something...
        def build_event(elements)
          return if elements.empty?

          data.merge!(attributes(elements.first))
          items.replace(
            elements.first.elements.map { |i| item(i) }
          )
        end

        def item(element)
          Item.new(*attributes(element).values_at(:id, :sku, :partner_sku, :quantity, :project_id))
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
      Canceled = Class.new(SuccessEvent)
      Complete = Class.new(SuccessEvent)
      InProduction = Class.new(SuccessEvent)
      Shipment = Class.new(SuccessEvent)

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
