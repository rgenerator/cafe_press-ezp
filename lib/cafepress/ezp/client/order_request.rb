require 'cafepress/ezp/client/request'

module CafePress
  module EZP
    class Client
      class OrderRequest < Request # :nodoc:
        ENDPOINT = 'order.ezprints.com/PostXmlOrder.axd'
        # ?PartnerNumber=XXX&PartnerReference=yyy

        def initialize(params = {})
          @vendor = params[:vendor] || {}
          super
        end

        protected

        def build_response(doc)
          case doc.root.name
          when 'XmlOrderFailed'
            reason = doc.get_text('/XmlOrderFailed/Reason').to_s.strip
            reason = 'unknown' if reason.empty?
            raise OrderError, "order request failed: #{reason}"
          when 'XmlOrder'
            ref = doc.get_text('/XmlOrder/Reference').to_s.strip
            raise OrderError, 'order response is missing reference number' if ref.empty?
            ref
          else
            raise OrderError, "unknown response: #{body}"
          end
        end

        def build_request(xml)
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
      end
    end
  end
end
