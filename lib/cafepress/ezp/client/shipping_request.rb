require 'cafepress/ezp/client/request'

module CafePress
  module EZP
    class Client
      class ShippingRequest < Request
         ENDPOINT = "services.ezprints.com/ShippingCalculator/CalculateShipping.axd"
      end
    end
  end
end
