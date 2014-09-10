require 'rexml/document'
require 'cafepress/ezp/client/request'

module CafePress
  module EZP
    class Client
      class OrderRequest < Request # :nodoc:
        ENDPOINT = 'order.ezprints.com/PostXmlOrder.axd'
        # ?PartnerNumber=XXX&PartnerReference=yyy

        def initialize(params = {})
          @vendor = params[:vendor]
          super
        end

        protected
        def build_response(body)
          # TODO: Malformed XML is accepted
          # doc.get_elements(xpath)
          doc = REXML::Document.new(body)
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
          build_order_session(xml, @order) do
            build_vendor(xml)
            build_customer(xml)
            build_order(xml)
          end
        end

        def build_vendor(xml)
          xml.tag! 'vendor' do
            build_address(xml, @vendor)
          end
        end
      end
    end
  end
end
