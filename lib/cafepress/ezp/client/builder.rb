require 'builder'

# Monkey patch this so that nil elements and attributes (TODO) are not rendered
module Builder
  class XmlMarkup
    alias_method :old_tag!, :tag!
    def tag!(sym, *args, &block)
      # TODO: nil attributes?
      return '' if args.size == 1 and args.first.nil?
      old_tag!(sym, *args, &block)
    end
  end
end
