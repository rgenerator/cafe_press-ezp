require 'cafepress/ezp/client/version'
require 'cafepress/ezp/client/order_request'
require 'cafepress/ezp/client/shipping_request'


module CafePress
  module EZP
    ##
    # == Partner Id
    #
    # Using this class requires a CafePress partner id
    #
    # == Types
    #
    # Methods accept hashes and arrays of hashes, each hash is described below.
    #
    # === :customer
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
    # === +:images+
    #
    # An array of hashes, each hash may have the following entries:
    #
    # * +:id+
    # * +:title+
    # * +url+ (String) - URL where the image can be found
    #
    # === :order
    #
    # * :id (String|Integer) - How the vendor IDs this order
    # * :product_total (String|Float)
    # * :shipping_total (String|Float)
    # * :tax_total (String|Float)
    # * :total (String|Float)
    # * :shipping_method (String) - Must be one of: FC, PM, TD, SD, ON
    #
    # === :order_items
    #
    # An array of hashes, each hash may have the following entries:
    #
    # * :product_id (String|Integer) - CafePress product SKU
    # * :name (String)
    # * :price (String|Float)
    # * :project_id (String) - One can provide this in lieu of +:product_id+, +:name+, and +:price+
    # * +:quantity+ (+String+|+Integer+)
    # * +:images+ (+Array+) - See +:images+ section
    #
    # === :ship_address
    #
    # Same as Customer
    #
    # === :vendor
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

    class Client
      Error = Class.new(StandardError)
      RequestError = Class.new(Error)
      OrderError = Class.new(Error)

      # === Arguments
      #
      # [partner_id (String)]
      # [vendor (Hash)] Default +vendor+. Orders without a vendor will use this one.
      #
      # === Errors
      #
      # [ArgumentError] If a provider id was not provided

      def initialize(partner_id, vendor = {})
        raise ArgumentError, 'partner_id is required' if partner_id.to_s.empty?

        @partner_id = partner_id
        @vendor = vendor
      end

      # Send an order to CafePress for processing. If no +:shipping_address+ is given, +customer+ will be used as
      # the shipping address.
      #
      # === Arguments
      #
      # [customer (Hash)]
      # [order (Hash)]
      # [order_items (Array)] An array of hashes
      # [extras (Hash)] Optional items to include in the request. Can be any of +:images+, +:shipping_address+, +:vendor+.
      #
      # === Returns
      #
      # [reference_number (String)] When successful the order's reference number is returned
      #
      # === Errors
      #
      # [RequestError] An error was encountered during the request/response cycle
      # [OrderError] Order submission failed

      def place_order(customer, order, order_items, extras = {})
        req = Client::OrderRequest.new(:partner_id => @partner_id,
                                       :vendor => extras[:vendor] || @vendor,
                                       :customer => customer,
                                       :order => order,
                                       :order_items => order_items,
                                       :shipping_address => extras[:shipping_address] || customer,
                                       :images => extras[:images])
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
