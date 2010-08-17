class SerializableProc

  class CannotSerializeVariableError < Exception ; end

  class Binding

    include Marshalable
    marshal_attr :vars

    def initialize(binding, sexp)
      sexp, @vars = sexp.gsub(s(:scope, s(:block, SexpAny.new)), nil), {}
      types, n_sexp = Sandboxer.isolatable_types(sexp)
      unless types.empty?
        sexp_str = n_sexp.inspect
        while m = sexp_str.match(/^(.*?s\(:(?:#{types.join('|')})var, :([^\)]+)\))/)
          ignore, var = m[1..2]
          sexp_str.sub!(ignore,'')
          begin
            val = eval(var, binding) rescue nil
            @vars.update(Sandboxer.fvar(var) => mclone(val))
          rescue TypeError
            raise CannotSerializeVariableError.new("Variable #{var} cannot be serialized !!")
          end
        end
      end
    end

    def eval!(binding = nil)
      unless binding
        @binding ||= (
          eval(declare_vars, binding = Kernel.binding)
          binding
        )
      else
        eval(declare_vars, binding)
        binding
      end
    end

    private

      def declare_vars
        @declare_vars ||= @vars.map{|(k,v)| "#{k} = Marshal.load(%|#{mdump(v)}|)" } * '; '
      end

  end
end
