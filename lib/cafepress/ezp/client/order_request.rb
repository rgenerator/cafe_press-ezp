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
        def build_request(xml)
          build_order_session(xml, @order) do
            # ...
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
