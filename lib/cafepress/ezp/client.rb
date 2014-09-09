require 'cafepress/ezp/client/version'

module CafePress
  module EZP
    class Client
      Error = Class.new(StandardError)
      RequestError = Class.new(Error)

      # If you send one order per ordersession, it is recommended that your ordersessionID be
      # the same as your internal orderID for clarity in reporting.

      # if you offer a "package" of products that in your system is one productid (e.g. your product009
      # is a set of 2 4x6 prints, 1 8x10 and 1 sheet of address labels), it needs to be broken down
      # into unique EZP productids per orderline.
      def initialize(options = {})
        #@partner_id = partner_id
        #@vendor = vendor
      end

      def place_order(customer, order, order_items, ship_address = nil, vendor = nil)
        req = Client::OrderRequest.new(:partner_id => @partner_id,
                                       :vendor => vendor || @vendor,
                                       :customer => customer,
                                       :order => order,
                                       :order_items => order_items,
                                       :shipping_address => shipping_address || customer)
        req.send
      end

      def shipping_options(customer, order, order_items, ship_address = nil)
        req = Client::ShippingRequest.new(:partner_id => @partner_id,
                                          :customer => customer,
                                          :order => order,
                                          :order_items => order_items,
                                          :shipping_address => shipping_address || customer)
        req.send
      end
    end
  end
end
