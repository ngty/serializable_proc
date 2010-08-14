class SerializableProc
  module Parsers
    module PT
      class << self
        def process(block)
          if Object.const_defined?(:ParseTree)
            sexp = block.to_sexp
            runnable_code = RUBY_2_RUBY.process(Sandboxer.fsexp(sexp))
            extracted_code = RUBY_2_RUBY.process(eval(sexp.inspect))
            [{:runnable => runnable_code, :extracted => extracted_code}, sexp]
          end
        end
      end
    end
  end
end
