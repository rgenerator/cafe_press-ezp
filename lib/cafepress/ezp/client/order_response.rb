require 'rexml/document'

module CafePress
  module EZP
    class Client
      class OrderResponse
        def initialize(xml)
          doc = REXML::Document.new(xml)
          if doc.root.name == "XmlOrderFailed"
            # ...
          end
          # doc.get_elements(xpath)
        end
      end
    end
  end
end
