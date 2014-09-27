class SerializableProc
  module Isolatable

    ISOLATION_TYPES = [:local, :class, :instance, :global]
    MAPPERS = {'l' => '', 'c' => '@@', 'i' => '@', 'g' => '$'}
    ISOLATION_VAR = :@@_not_isolated_vars
    BLOCK_SCOPES = [:class, :sclass, :defn, :module]

    protected

      def isolatable_vars(sexp)
        sexp = sexp.to_a if sexp.is_a?(Sexp)
        return if BLOCK_SCOPES.include?(sexp[0])
        sexp.inject({}) do |memo, e|
          if e.is_a?(Array)
            memo.merge(isolatable_vars(e) || {})
          elsif e.to_s =~ /^((l|c|g|i)var_(\w+))$/
            memo.merge((MAPPERS[$2] + $3).to_sym => $1.to_sym)
          else
            memo
          end
        end
      end

      def isolated_sexp_and_code(sexp)
        sexp_arry, @types = sexp.to_a, isolated_types(sexp).join('|')
        sexp_arry = isolated_sexp_arry(sexp_arry) unless @types.empty?
        [
          Sexp.from_array(sexp_arry),
          Ruby2Ruby.new.process(Sexp.from_array(sexp_arry))
        ]
      end

    private

      def isolated_types(sexp)
        isolated_types = ISOLATION_TYPES # by default, isolate all

        # accept single symbols as well as arrays
        @isolate = [@isolate].flatten if @isolate
        @ignore = [@ignore].flatten if @ignore

        isolated_types = @isolate if @isolate && !@isolate.include?(:all)
        # backwards-compatibility for inline @@_not_isolated_vars syntax
        @ignore ||= isolatable_declarative(sexp).map(&:to_sym)
        ignored_types = @ignore.include?(:all) ? ISOLATION_TYPES : @ignore if @ignore

        ((isolated_types - ignored_types) & ISOLATION_TYPES).map{|e| e[0].chr }
      end

      def isolated_sexp_arry(array)
        return array if BLOCK_SCOPES.include?(array[0])
        array.map do |e|
          case e
          when Array
            if e.size == 2 && e[0].to_s =~ /^(#{@types})var$/
              isolatable?(var = e[1]) ? [:lvar, isolated_var(var,$1)] : e
            elsif e[0].to_s =~ /^(#{@types})(vdel|asgn)$/ && isolatable?(var = e[1])
              isolated_sexp_arry([:lasgn, isolated_var(var,$1), *e[2..-1]])
            else
              isolated_sexp_arry(e)
            end
          else
            e
          end
        end
      end

      def isolated_var(var, type = nil)
        m = var.to_s.match(/^(\W*)(\w+)$/)[1..2]
        type ||= MAPPERS.invert[m[0]]
        :"#{type}var_#{m[1]}"
      end

      def isolatable_declarative(sexp)
        declaratives = []
        [:cvdecl, :cvasgn].each do |type|
          sexp.each_of_type(type) do |node|
            next unless node.to_a[1] == ISOLATION_VAR
            node.each_of_type(:lit) {|_node| declaratives << _node.to_a[-1].to_s }
            break
          end
          break unless declaratives.empty?
        end
        declaratives
      end

      def isolatable?(var)
        var.to_s != ISOLATION_VAR.to_s
      end

  end
end
