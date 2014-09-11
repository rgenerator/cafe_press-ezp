require 'net/http'
require 'cafepress/ezp/builder'

module CafePress
  module EZP
    class Client

      # Subclasses must implement the following methods:
      #
      #   1. build_request(builder)
      #   2. build_response(body)
      #   3. endpoint => returns the endpoint as an instance of +URI+
      #
      class Request
        @@api_version = 1

        def initialize(params = {})
          @params = params.dup
        end

        def send
          res = send_request(build)
          build_response(res)
        end

        protected

        [:partner_id, :customer, :order, :shipping_address].each do |attr|
          define_method(attr) { @params[attr] ||= {} }
        end

        def order_items
          @params[:order_items] ||= []
        end

        def build
          xml = Builder::XmlMarkup.new
          xml.instruct!
          # TODO: may need partner_id in subclasses
          # TODO: images element
          xml.orders(:partnerid => @params[:partner_id], :version => @@api_version) { build_request(xml) }
          xml.target!
        end

        def send_request(body)
          # TODO: SSL option
          Net::HTTP.start(endpoint.host, endpoint.port, :use_ssl => false) do
            http.request_post(endpoint.path, body) do |res|
              # TODO: does it return non-200s when encoountering non-HTTP problem with request?
              raise RequestError, "request failed, returned HTTP #{res.code}" if res.code != "200"
              res.body
            end
          end
        rescue SystemCallError, SocketError => e
          raise RequestError, "failed to connect to #{endpoint}: #{e}"
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
              xml.position oi[:position] # CROP or FIT
              # xml.enhance oi[:enhance]  # enhancement algorithm should be applied to the image before printing
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
