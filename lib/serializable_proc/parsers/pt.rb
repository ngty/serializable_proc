class SerializableProc
  module Parsers
    module PT
      class << self
        def process(block)
          if Object.const_defined?(:ParseTree)
            sexp = block.to_sexp
            fsexp = Sandboxer.fsexp(sexp)
            runnable_code = RUBY_2_RUBY.process(Sexp.from_array(fsexp.to_a))
            extracted_code = RUBY_2_RUBY.process(Sexp.from_array(sexp.to_a))
            [
              {:runnable => runnable_code, :extracted => extracted_code},
              {:runnable => fsexp, :extracted => sexp}
            ]
          end
        end
      end
    end
  end
end
