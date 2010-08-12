class SerializableProc
  module Parsers
    module PT
      class << self
        def process(block)
          if Object.const_defined?(:ParseTree)
            sexp = block.to_sexp
            [RUBY_2_RUBY.process(Sandboxer.fsexp(sexp)), sexp]
          end
        end
      end
    end
  end
end
