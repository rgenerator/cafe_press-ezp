require 'cafe_press/ezp/client/request'

module CafePress
  module EZP
    class Client
      class OrderRequest < Request # :nodoc:
        ENDPOINT = 'https://order.ezprints.com/PostXmlOrder.axd'

        def initialize(params = {})
          @vendor = params[:vendor] || {}
          @images = params[:images] || []
          super
        end

        protected

        def endpoint
          ENDPOINT
        end

        def build_response(doc)
          case doc.root.name
          when 'XmlOrderFailed'
            reason = doc.root.attributes['Reason'].to_s.strip
            reason = 'no reason given' if reason.empty?
            raise OrderError, "order request failed: #{reason}"
          when 'XmlOrder'
            ref = doc.root.attributes['Reference'].to_s.strip
            raise OrderError, 'order response is missing reference number' if ref.empty?
            ref
          else
            raise OrderError, "unknown response: #{body}"
          end
        end

        def build_request(xml)
          build_images(xml)
          build_order_session(xml) do
            # This would be the sum of all orders but we only support one order so they're the same
            xml.producttotal order[:product_total]
            # xml.discounttotal
            xml.shippingtotal order[:shipping_total]
            xml.taxtotal order[:tax_total]
            xml.total order[:total]

            build_vendor(xml)
            build_customer(xml)
            build_order(xml) do
              xml.producttotal order[:product_total]
              # xml.discount
              xml.shippingprice order[:shipping_total]
              xml.tax order[:tax_total]
              xml.ordertotal order[:total]
            end
          end
        end

        def build_vendor(xml)
          xml.vendor do
            xml.name @vendor[:name]
            build_address(xml, @vendor)
            xml.url @vendor[:url]
          end
        end

        def build_images(xml)
          return if @images.none?

          xml.images do
            @images.each do |image|
              xml.uri(:id => image[:id], :title => image[:title]) { xml.text! image[:url] }
            end
          end
        end
      end
    end
  end
end
