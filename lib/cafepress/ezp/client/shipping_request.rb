require 'cafepress/ezp/client/request'

module CafePress
  module EZP
    class Client
      class ShippingRequest < Request # :nodoc:
        ENDPOINT = "services.ezprints.com/ShippingCalculator/CalculateShipping.axd"

        protected

        def build_response(doc)
          case doc.root.name
            when 'shippingOptions'
          end
        end

        def build_request(xml)
        end
      end
    end
  end
end
