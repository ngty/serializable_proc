class SerializableProc
  module Sandboxer
    class << self

      def fsexp(sexp)
        n_sexp, t_sexp = nil, sexp.inspect
        while m = t_sexp.match(/^(.*?s\(:)((i|l|c|g)(asgn|var|vdecl))(,\ :)((|@|@@|\$)([\w]+))(\)|,)/)
          orig, prepend, _, type, declare, join, _, _, name, append = m[0..-1]
          declare.sub!('vdecl','asgn')
          n_sexp = "#{n_sexp}#{prepend}l#{declare}#{join}#{type}var_#{name}#{append}"
          t_sexp.sub!(orig,'')
        end
        eval(n_sexp ? "#{n_sexp}#{t_sexp}" : sexp.inspect)
      end

      def fvar(var)
        @translate_var_maps ||= {'@' => 'ivar_', '@@' => 'cvar_', '$' => 'gvar_', '' => 'lvar_'}
        m = var.to_s.match(/^(|@|@@|\$)(\w+)$/)
        var.to_s.sub(m[1], @translate_var_maps[m[1]]).to_sym
      end

    end
  end
end
