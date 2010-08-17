class SerializableProc
  module Parsers
    class PT < Base
      class << self
        def process(block)
          if Object.const_defined?(:ParseTree)
            sexp_derivatives(block.to_sexp)
          end
        end
      end
    end
  end
end
