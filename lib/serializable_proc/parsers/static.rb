class SerializableProc

  class CannotAnalyseCodeError < Exception ; end

  module Parsers
    class Static < Base
      class << self

        def process(klass, file, line)
          const_set(:RUBY_PARSER, RubyParser.new) unless const_defined?(:RUBY_PARSER)
          @klass, @file, @line = klass, file, line
          extract_code_and_sexp
        end

        def matchers
          @matchers ||= []
        end

        private

          def extract_code_and_sexp
            sexp_str, remaining, @marker = extract_sexp_args
            while frag = remaining[/^([^\)]*\))/,1]
              begin
                sexp = normalized_eval(sexp_str += frag)
                return sexp_derivatives(sexp){|code| unescape_magic_vars(code) }
              rescue SyntaxError
                remaining.sub!(frag,'')
              end
            end
          end

          def normalized_eval(sexp_str)
            sexp = eval(sexp_str) # this will fail unless the sexp is valid
            sexp.delete(marker_sexp = s(:call, nil, :"#{@marker}", s(:arglist)))
            sexp.find_node(:block).delete(marker_sexp) rescue nil
            if (block = sexp.find_node(:block)) && block.to_a.size == 2
              sexp.gsub(block, Sexp.from_array(block.to_a[1]))
            else
              sexp
            end
          end

          def extract_sexp_args
            raw, marker = raw_sexp_and_marker
            regexp = Regexp.new(
              '^(.*(' + Regexp.quote('s(:iter, s(:call, nil, :') +
              '(?:proc|lambda)' + Regexp.quote(', s(:arglist') +
              '.*?' + Regexp.quote("s(:call, nil, :#{marker}, s(:arglist))") +
              '))(.*)$', Regexp::MULTILINE
            )
            [raw.match(regexp)[2..3], marker].flatten
          end

          def raw_sexp_and_marker
            # TODO: Ugly chunk, need some lovely cleanup !!
            (%W{#{@klass}\.new lambda|proc|Proc\.new} + matchers).each do |declarative|
              regexp = /^((.*?)(#{declarative})(\s*(?:do|\{)\s*(?:\|(?:[^\|]*)\|\s*)?)(.*)?)$/m
              raw = raw_code
              lines1, lines2 = [(0 .. (@line - 2)), (@line.pred .. -1)].map{|r| raw[r] }
              prepend, type, block_start, append = lines2[0].match(regexp)[2..5] rescue next

              if lines2[0] =~ /^(.*?\W)?(#{declarative})(\W.*?\W(#{declarative}))+(\W.*)?$/
                msg = "Static code analysis can only handle single occurrence of '%s' per line !!" %
                  declarative.split('|').join("'/'")
                raise CannotAnalyseCodeError.new(msg)
              elsif lines2[0] =~ /^(.*?\W)?(#{declarative})(\W.*)?$/
                marker = "__serializable_proc_marker_#{@line}__"
                line = "#{prepend}proc#{block_start} #{marker}; #{append}"
                lines = lines1.join + escape_magic_vars(line + lines2[1..-1].join)
                return [RUBY_PARSER.parse(lines).inspect, marker]
              end
            end
            raise CannotAnalyseCodeError.new('Cannot find specified initializer !!')
          end

          def escape_magic_vars(s)
            %w{__FILE__ __LINE__}.inject(s) do |s, var|
              s.gsub(var, "__serializable_proc_#{var.downcase}__")
            end
          end

          def unescape_magic_vars(s)
            %w{__FILE__ __LINE__}.inject(s) do |s, var|
              s.gsub("__serializable_proc_#{var.downcase}__", var)
            end
          end

          def raw_code
            File.readlines(@file)
          end

      end
    end
  end
end

