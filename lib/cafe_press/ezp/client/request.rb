require 'net/http'
require 'uri'
require 'rexml/document'

require 'cafe_press/ezp/client/builder'

module CafePress
  module EZP
    class Client

      # Subclasses must implement the following methods:
      #
      # 1. build_request(builder)
      # 2. build_response(doc)
      # 3. endpoint => returns the URL for the request as a +String+

      class Request # :nodoc:
        VERSION = 1
        HEADERS = { 'Content-Type' => 'application/xml' }

        def initialize(params = {})
          @params = params.dup
        end

        def send
          res = send_request(build)

          begin
            doc = REXML::Document.new(res)
          rescue REXML::ParseException => e
            raise RequestError, "response contains invalid XML: #{e}"
          end

          build_response(doc)
        end

        protected

        [:partner_id, :customer, :order, :shipping_address].each do |attr|
          define_method(attr) { @params[attr] ||= {} }
        end

        def order_items
          @params[:order_items] ||= []
        end

        def webhook
          @params[:webhook]
        end

        def build
          xml = Builder::XmlMarkup.new
          xml.instruct!
          # TODO: may need partner_id in subclasses
          xml.orders(:partnerid => @params[:partner_id], :version => VERSION, :NotificationUri => webhook) { build_request(xml) }
          xml.target!
        end

        def send_request(body)
          url  = URI(endpoint)
          path = sprintf('%s?PartnerNumber=%s', url.path, URI.escape(partner_id.to_s))

          begin 
            http = Net::HTTP.new(url.host, url.port)
            http.set_debug_output($stderr) if $DEBUG
            http.use_ssl = true
            res = http.post(path, body, HEADERS)
          rescue => e 
            # There are probably 5 exceptions here, so we'll just catch um all
            raise RequestError, "request failed: #{e}"
          end

          raise RequestError, "request failed, returned HTTP status #{res.code}" if res.code != "200"
          res.body
        end

        def build_order_session(xml)
          xml.ordersession do
            xml.sessionid order[:id]
            yield if block_given?
          end
        end

        def build_order(xml)
          xml.order do
            xml.orderid order[:id]
            xml.shippingmethod order[:shipping_method]
            build_shipping_address(xml)
            build_order_lines(xml)

            yield if block_given?
          end
        end

        def build_order_totals(xml)
          xml.producttotal order[:product_total]
          xml.shippingtotal order[:shipping_total]
          xml.taxtotal order[:tax_total]
          xml.total order[:total]
        end

        def build_order_lines(xml)
          # @imageid, affiliatekey

          order_items.each do |oi|
            xml.orderline :productid => oi[:product_id], :ProjectId => oi[:project_id] do
              xml.description oi[:description]
              xml.productprice oi[:price]
              xml.quantity oi[:quantity]
              xml.position oi[:position]
              # xml.enhance oi[:enhance]  # enhancement algorithm should be applied to the image before printing
              # Array(oi[:images]).each do |image|
              # xml.orderlineimages
            end
          end
        end

        def build_customer(xml)
          xml.customer { build_customer_address(xml, customer) }
        end

        def build_shipping_address(xml)
          xml.shippingaddress { build_customer_address(xml, shipping_address) }
        end

        def build_customer_address(xml, customer)
          xml.companyname customer[:company]
          xml.firstname customer[:first_name]
          xml.lastname customer[:last_name]
          build_address(xml, customer)
        end

        def build_address(xml, address)
          [:address1, :address2, :city, :state, :zip, :country, :phone, :email].each do |name|
            element =  name == :country ? 'countrycode' : name
            xml.tag! element, address[name]
          end
        end
      end
    end
  end
end
