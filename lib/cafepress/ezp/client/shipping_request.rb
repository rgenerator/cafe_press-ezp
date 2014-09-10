require 'cafepress/ezp/client/request'

module CafePress
  module EZP
    class Client
      class ShippingRequest < Request # :nodoc:
        ENDPOINT = "services.ezprints.com/ShippingCalculator/CalculateShipping.axd"

        protected

        def build_response(body)
        end

        def build_request(xml)
        end
      end
    end
  end
end
