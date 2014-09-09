require 'builder'
require 'net/http'

module CafePress
  module EZP
    class Client

      # Subclasses must implement the following methods:
      #
      #   1. build(doc)
      #   2. endpoint => returns the endpoint as an instance of +URI+
      #
      class Request
        @@api_version = 1

        def initialize(params = {})
          @params = params.dup
        end

        def send
          body = build(xml)
          build_response(send_request(body))
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
          xml.tag!('orders', :partnerid => @params[:partner_id], :version => @@api_version) { build_request(xml) }
          xml.to_xs
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
          xml.tag! 'ordersession' do
            xml.tag! 'ordersession' do
              xml.tag! 'sessionid', order[:id]

              yield xml

              build_order_totals(xml)
            end
          end
        end

        def build_order(xml)
          xml.tag! 'order' do
            xml.tag! 'orderid', order[:id]
            build_shipping_address(xml)
            xml.tag! 'shippingmethod', order[:shipping_method]
            build_order_lines(xml)

            yield xml
          end
        end

        def build_order_totals(xml)
          xml.tag! 'producttotal', order[:product_total]
          xml.tag! 'shippingtotal', order[:shipping_total]
          xml.tag! 'taxtotal', order[:tax_total]
          xml.tag! 'total', order[:total]
        end

        def build_order_lines(xml)
          # @imageid, affiliatekey

          order_items.each do |oi|
            xml.tag! 'orderline', :productid => oi[:product_id] do
              xml.tag! 'quantity', oi[:quantity]
              # xml.tag! 'position', oi[:position] # crop or fix
              xml.tag! 'productprice', oi[:price]
              xml.tag! 'productname', oi[:name]
              # xml.tag! 'enhance', oi[:enhance]  # enhancement algorithm should be applied to the image before printing
            end
          end
        end

        def build_customer(xml, customer)
          xml.tag! 'customer' do
            build_address(xml, customer)
          end
        end

        def build_shipping_address(xml, address)
          xml.tag! 'shippingaddress' do
            build_address(xml, address)
          end
        end

        def build_address(xml, address)
          [:first_name, :last_name, :address1, :address2, :city, :state, :zip, :country, :phone].each do |name|
            element =  name == :country ? 'countrycode' : name
            xml.tag! element, customer[name]
          end
        end
      end
    end
  end
end
