require 'builder'

module CafePress
  module EZP
    class Client
      class Builder < Builder::XmlMarkup

        def tag!(sym, *args, &block)
          args.compact!

          if args.last.is_a?(::Hash)
            attr = args.last
            attr.reject! { |k,v| v.nil? }
            args.pop if attr.empty?
          end

          return '' if args.empty? && block.nil?

          super
        end
      end
    end
  end
end
