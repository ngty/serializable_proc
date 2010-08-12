class SerializableProc
  class Binding

    include Marshalable
    marshal_attr :vars

    def initialize(binding, sexp)
      @vars, sexp_str = {}, sexp.inspect
      while m = sexp_str.match(/^(.*?s\(:(?:l|g|c|i)var, :([^\)]+)\))/)
        ignore, var = m[1..2]
        sexp_str.sub!(ignore,'')
        begin
          val = binding.eval(var) rescue nil
          @vars.update(Sandboxer.fvar(var) => mclone(val))
        rescue TypeError
          raise CannotSerializeVariableError.new("Variable #{var} cannot be serialized !!")
        end
      end
    end

    def eval!
      @binding ||= (
        set_vars = @vars.map{|(k,v)| "#{k} = Marshal.load(%|#{mdump(v)}|)" } * '; '
        (binding = Kernel.binding).eval(set_vars) ; binding
      )
    end

  end
end
