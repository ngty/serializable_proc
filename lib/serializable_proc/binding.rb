class SerializableProc

  class CannotSerializeVariableError < Exception ; end

  class Binding

    include Marshalable
    marshal_attr :vars

    def initialize(binding, sexp)
      @sexp, @vars = sexp.gsub(s(:scope, s(:block, SexpAny.new)), nil), {}
      unless (types = extract_isolated_types).empty?
        sexp_str = @sexp.inspect
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

      def extract_isolated_types
        o_sexp_arry = @sexp.to_a
        @sexp = @sexp.gsub(s(:cvdecl, :@@_not_isolated_vars, SexpAny.new), nil)
        types = %w{global instance local class}

        if (diff = o_sexp_arry - @sexp.to_a).empty?
          types.map{|t| t[0].chr }
        else
          sexp_str = Sexp.from_array(diff).inspect
          types.map{|t| t[0].chr unless sexp_str.include?("s(:lit, :#{t})") }.compact
        end
      end

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
