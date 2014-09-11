require 'cafepress/ezp/client/version'
require 'cafepress/ezp/client/order_request'
require 'cafepress/ezp/client/shipping_request'


module CafePress
  module EZP
    class Client
      Error = Class.new(StandardError)
      RequestError = Class.new(Error)
      OrderError = Class.new(Error)

      # == Partner Id
      #
      # Using this class requires a CafePress partner id
      #
      # == Types
      #
      # Methods accept hashes and arrays of hashes, each hash is described below.
      #
      # === Customer
      #
      # * :company (String)
      # * :first_name (String)
      # * :last_name (String)
      # * :address1 (String)
      # * :address2 (String)
      # * :city (String)
      # * :country (String) - ISO 3166-1 alpha-3 county code
      # * :email (String)
      # * :phone (String)
      # * :state (String)
      # * :zip (String)
      #
      # === Order
      #
      # * :id (String|Integer)
      # * :product_total (String|Float)
      # * :shipping_total (String|Float)
      # * :tax_total (String|Float)
      # * :total (String|Float)
      # * :shipping_method (String) - Must be one of: FC, PM, TD, SD, ON
      #
      # === Order Items
      #
      # An array of hashes, each hash may have the following entries:
      #
      # * :product_id (String|Integer) - CafePress product SKU
      # * :name (String)
      # * :price (String|Float)
      # * :project_id (String) - Instead of :product_id, :name, and :price one can provide a :project_id
      # * :quantity (String|Integer)
      #
      # === Ship Address
      #
      # Same as Customer
      #
      # === Vendor
      #
      # * :name (String)
      # * :url (String)
      # * :address1 (String)
      # * :address2 (String)
      # * :city (String)
      # * :country (String) - ISO 3166-1 alpha-3 county code
      # * :email (String)
      # * :phone (String)
      # * :state (String)
      # * :zip (String)

      def initialize(partner_id, vendor = {})
        @partner_id = partner_id
        @vendor = vendor
      end

      # Send an order to CafePress for processing
      #
      # === Arguments
      #
      # [customer (Hash)]
      # [order (Hash)]
      # [order_items (Array)] An +Array+ of +Hash+es
      # [ship_address (Hash)] Optional. The address to send the order to, defaults to the address
      #                       given by +customer+.
      # [vendor (Hash)] Optional. Defaults to the vendor given upon initialization.
      #
      # === Returns
      #
      # [reference_number (String)] When successful the order's reference number is returned
      #
      # === Errors
      #
      # [RequestError] A connection cannot be made to CafePress' server
      # [OrderError] Order submission failed

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
