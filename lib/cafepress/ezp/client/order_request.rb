require 'cafepress/ezp/client/request'

module CafePress
  module EZP
    class Client
      class OrderRequest < Request
        ENDPOINT = "order.ezprints.com/PostXmlOrder.axd"
        # ?PartnerNumber=XXX&PartnerReference=yyy
      end
    end
  end
end
