class SerializableProc

  class CannotSerializeVariableError < Exception ; end

  class Binding

    include Isolatable
    include Marshalable
    marshal_attr :vars

    def initialize(binding, sexp)
      non_block_scoped_sexp = sexp.gsub(s(:scope, s(:block, SexpAny.new)), nil)
      @vars = extract_bounded_vars(binding, non_block_scoped_sexp) || {}
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

      def extract_bounded_vars(binding, sexp)
        unless (types = isolated_types(sexp)).empty?
          vars, pattern = {}, %r{s\(:((?:#{types.join('|')})var),\ :((?:|@|@@|\$)(\w+))\)}
          sexp.inspect.gsub(pattern) do |s|
            type, o_var, name = s.match(pattern)[1..3]
            if isolatable?(o_var)
              vars.update(:"#{type}_#{name}" => bounded_val(o_var, binding))
            end
          end
          vars
        end
      end

      def bounded_val(var, binding)
        begin
          val = eval(var, binding) rescue nil
          mclone(val)
        rescue TypeError
          raise CannotSerializeVariableError.new("Variable #{var} cannot be serialized !!")
        end
      end

  end
end
