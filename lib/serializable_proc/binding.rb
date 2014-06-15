class SerializableProc

  class CannotSerializeVariableError < Exception ; end

  class Binding

    include Isolatable
    include Marshalable
    marshal_attr :vars

    def initialize(binding, sexp)
      @vars = isolatable_vars(sexp).inject({}) do |memo, (o_var, n_var)|
        memo.merge(n_var => bounded_val(o_var, binding))
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
        @declare_vars ||= @vars.map{|(k,v)| "#{k} = Marshal.load(%q|#{mdump(v)}|)" } * '; '
      end

      def bounded_val(var, binding)
        begin
          val = eval(var.to_s, binding) rescue nil
          mclone(val)
        rescue TypeError
          raise CannotSerializeVariableError.new("Variable #{var} cannot be serialized !!")
        end
      end

  end
end
