class SerializableProc
  module Parsers
    class Dynamic < Base
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
