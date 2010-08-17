class SerializableProc

  class CannotSerializeVariableError < Exception ; end

  class Binding

    include Marshalable
    marshal_attr :vars

    def initialize(binding, sexp)
      sexp, @vars = sexp.gsub(s(:scope, s(:block, SexpAny.new)), nil), {}
      types, sexp = Sandboxer.isolatable_types(sexp)
      unless types.empty?
        sexp_str = sexp.inspect
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

    def eval!
      @binding ||= (
        set_vars = @vars.map{|(k,v)| "#{k} = Marshal.load(%|#{mdump(v)}|)" } * '; '
        eval(set_vars, binding = Kernel.binding)
        binding
        # binding.extend(Extensions)
      )
    end

    private

      module Extensions
        def self.extended(base)
          class << base

            alias_method :orig_eval, :eval

            def eval(str)
              begin
                @fvar = Sandboxer.fvar(str).to_s
                orig_eval(@fvar)
              rescue NameError => e
                msg = e.message.sub(@fvar, str)
                raise NameError.new(msg)
              end
            end

          end
        end
      end

  end
end
