module CafePress
  module EZP
    module Events
      # Move Client::Error to EZP::Error?
      # EventError = Class.new(Error)

      Order = Struct.new(:id, :reference_number)
      Item = Struct.new(:id, :sku, :partner_sku, :quantity)

      class SuccessEvent
        attr_accessor :order, :data, :items

        def initialize(order)
          @items = []
          @order = Order.new(*order.attributes.values_at('Id', 'EZPReferenceNumber'))
          @data = { date_time: order.children[0].attributes['DateTime'] }

          build_event(order.children)
        end

        protected

        def build_event(elements)
          # nothing
        end

        def item(element)
          Item.new(attributes(element).values_at(:id, :sku, :partner_sku, :quantity))
        end

        def attributes(element)
          element.attributes.each_with_object({}) do |(name, value), hash|
            hash[ underscore(name) ] = value
            hash
          end
        end

        def underscore(s)
          s.gsub(/([a-z0-9])([A-Z])/) { "#{$1}_#{$2}" }.downcase
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
            elements.first.children.map { |i| item(i) }
          )
        end
      end

      class Failed
        attr_accessor :order, :data, :items

        def initialize(doc)
          @items = []  # for compatibility with other events
          @order = Order.new(doc.get_text('/ordernumber'), doc.get_text('/referencenumber'))
          @data = { message: doc.get_text('/message'), affiliate_id: doc.attributes['AffiliateID'] }
        end
      end
    end
  end
