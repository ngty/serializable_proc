class SerializableProc
  module Isolatable

    protected

      def isolated_sexp(sexp)
        eval (types = isolated_types(sexp)).empty? ? sexp.inspect : (
          bypass_scoping_by_block(sexp) do |sexp_str|
            # NOTE: for performance issue, we play around with the sexp string, rather
            # than the actual sexp.
            isolated_sexp_str_for_typed_vars(sexp_str, types)
          end
        )
      end

      def bypass_scoping_by_block(sexp)
        tmp_marker = :_serializable_proc_block_scope_marker_
        s_sexp = sexp.gsub(s(:scope, s(:block, SexpAny.new)), tmp_marker)
        pattern = %r{^#{Regexp.quote(s_sexp.inspect).gsub(tmp_marker.inspect,'(.*?)')}$}
        orig_blocks = sexp.inspect.match(pattern)[1..-1] rescue []
        n_sexp_str = yield(s_sexp.inspect)
        orig_blocks.inject(n_sexp_str) do |sexp_str, block_sexp_str|
          sexp_str.sub(tmp_marker.inspect, block_sexp_str)
        end
      end

      def isolated_sexp_str_for_typed_vars(o_sexp_str, types)
        n_sexp_str = nil
        var_pattern = /^(.*?s\(:)((#{types.join('|')})(asgn|var|vdecl))(,\ :)((|@|@@|\$)([\w]+))(\)|,)/

        while m = o_sexp_str.match(var_pattern)
          orig, prepend, _, type, declare, join, var, _, name, append = m[0..-1]
          n_sexp_str = isolatable?(var) ?
            "#{n_sexp_str}#{prepend}l#{declare.sub('vdecl','asgn')}#{join}#{type}var_#{name}#{append}" :
            "#{n_sexp_str}#{orig}"
          o_sexp_str.sub!(orig,'')
        end

        "#{n_sexp_str}#{o_sexp_str}"
      end

      def isolated_types(sexp)
        o_sexp_arry = sexp.to_a
        n_sexp = sexp.gsub(s(:cvdecl, :@@_not_isolated_vars, SexpAny.new), nil)
        types = %w{global instance local class}

        if (diff = o_sexp_arry - n_sexp.to_a).empty?
          types.map{|t| t[0].chr }
        else
          sexp_str = Sexp.from_array(diff).inspect
          sexp_str.include?("s(:lit, :all)") ? [] :
            types.map{|t| t[0].chr unless sexp_str.include?("s(:lit, :#{t})") }.compact
        end
      end

      def isolatable?(var)
        var != '@@_not_isolated_vars'
      end

  end
end
