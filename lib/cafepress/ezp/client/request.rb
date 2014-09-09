require 'builder'
require 'net/http'

module CafePress
  module EZP
    class Client
      class Request
        @@api_version = 1

        def send
          req = Net::HTTP.new(endpoint)
          xml = Builder::XmlMarkup.new
          xml.instruct!
          build(xml)
          req.xxx = xml.to_xs
        end

        protected
        def build_customer(xml, customer)
          xml.tag! 'customer' do
            # url???
            [:first_name, :last_name, :address1, :address2, :city, :state, :zip, :country, :phone].each do |name|
              element =  name == :country ? 'countrycode' : name
              xml.tag! element, customer[name]
            end
          end
        end
      end
    end
  end
end
