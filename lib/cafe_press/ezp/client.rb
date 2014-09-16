require 'cafe_press/ezp'
require 'cafe_press/ezp/client/order_request'
require 'cafe_press/ezp/client/shipping_request'

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
      RequestError = Class.new(EZPError)
      OrderError = Class.new(EZPError)

      Webhook = Struct.new(:base, :endpoint) do  # :nodoc:
        def for(name)
          return base unless endpoint.include?(name)
          return endpoint[name] if endpoint[name].start_with?('http') || base.nil?
          # Cheap way to normalize directory separators
          URI.join(base, endpoint[name]).to_s
        end
      end

      # URLs that CafePress will call for event notification. For example:
      #
      #    Client.webhooks.base  = 'https://example.com/cafe_press'
      #    Client.webhooks.endpoint[:place_order] = '/orders'
      #
      # Calls to +place_order+ will call back to <code>https://example.com/cafe_press/orders</code>.
      # Calls to +shipping_options+ will call back to <code>https://example.com/cafe_press</code>.
      #
      # You can also use different URLs for each endpoint:
      #
      #    Client.webhooks.endpoint[:place_order] = 'http://x.com'
      #
      # By default these are not set and event notification will go to a pre-configured URL setup
      # by CafePress.

      def self.webhooks
        @@webhoks ||= Webhook.new(nil, {})
      end

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
                                       :images => extras[:images],
                                       :webhook => self.class.webhooks.for(:place_order))
        req.send
      end

      def shipping_options(customer, order, order_items, ship_address = nil)
        req = Client::ShippingRequest.new(:partner_id => @partner_id,
                                          :customer => customer,
                                          :order => order,
                                          :order_items => order_items,
                                          :shipping_address => shipping_address || customer,
                                          :webhook => self.class.webhooks.for(:shipping_options))
        req.send
      end
    end
  end
end
