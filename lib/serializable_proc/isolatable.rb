class SerializableProc
  module Isolatable

    protected

      def isolated_sexp(sexp)
        # TODO: This nasty mess needs some loving touch !!
        block_replace = :_serializable_proc_block_scope_marker_
        t_sexp = sexp.gsub(s(:scope, s(:block, SexpAny.new)), block_replace)
        blocks_pattern = %r{^#{Regexp.quote(t_sexp.inspect).gsub(block_replace.inspect,'(.*?)')}$}
        blocks = sexp.inspect.match(blocks_pattern)[1..-1] rescue []
        n_sexp_str = nil

        unless (types = isolated_types(sexp)).empty?
          var_pattern = /^(.*?s\(:)((#{types.join('|')})(asgn|var|vdecl))(,\ :)((|@|@@|\$)([\w]+))(\)|,)/
          t_sexp_str = t_sexp.inspect

          while m = t_sexp_str.match(var_pattern)
            orig, prepend, _, type, declare, join, var, _, name, append = m[0..-1]
            n_sexp_str = isolatable?(var) ?
              "#{n_sexp_str}#{prepend}l#{declare.sub('vdecl','asgn')}#{join}#{type}var_#{name}#{append}" :
              "#{n_sexp_str}#{orig}"
            t_sexp_str.sub!(orig,'')
          end

          n_sexp_str = n_sexp_str.nil? ? nil :
            blocks.inject("#{n_sexp_str}#{t_sexp_str}") do |sexp_str, block_str|
              sexp_str.sub(block_replace.inspect, block_str)
            end
        end

        eval(n_sexp_str ? n_sexp_str : sexp.inspect)
      end

      def isolated_var(var)
        @translate_var_maps ||= {'@' => 'ivar_', '@@' => 'cvar_', '$' => 'gvar_', '' => 'lvar_'}
        m = var.to_s.match(/^(|@|@@|\$)(\w+)$/)
        var.to_s.sub(m[1], @translate_var_maps[m[1]]).to_sym
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
