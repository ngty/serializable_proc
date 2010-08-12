class SerializableProc
  module Parsers
    module RP
      class << self

        def process(klass, file, line)
          const_set(:RUBY_PARSER, RubyParser.new) unless const_defined?(:RUBY_PARSER)
          @klass, @file, @line = klass, file, line
          extract_code_and_sexp
        end

        private

          def extract_code_and_sexp
            sexp_str, remaining = extract_sexp_args
            while frag = remaining[/^([^\)]*\))/,1]
              begin
                sexp = eval(sexp_str += frag) # this throws SyntaxError if sexp is invalid
                code = unescape_magic_vars(RUBY_2_RUBY.process(Sandboxer.fsexp(sexp))).
                  sub(/(#{@klass}\.new|Proc\.new|proc)/,'lambda').
                  sub(/__serializable_(lambda|proc)_marker__\(\d+\)\s*;?\s*\n?/m,'')
                return [code, sexp]
              rescue SyntaxError
                remaining.sub!(frag,'')
              end
            end
          end

          def extract_sexp_args
            raw, marker = raw_sexp_and_marker
            rq = lambda{|s| Regexp.quote(s) }
            regexp = Regexp.new([
              '^(.*(', (
                case marker
                when /(#{@klass}|Proc)/ then rq["s(:iter, s(:call, s(:const, :#{$1}), :new, s(:arglist)),"]
                else rq['s(:iter, s(:call, nil, :'] + '(?:proc|lambda)' + rq[', s(:arglist']
                end
              ),
              '.*?',
              rq["s(:call, nil, :__serializable_proc_marker__, s(:arglist, s(:lit, #{@line})))"],
              '))(.*)$'
            ].join, Regexp::MULTILINE)
            raw.match(regexp)[2..3]
          end

          def raw_sexp_and_marker
            regexp = /^(.*?(#{@klass}\.new|lambda|proc|Proc\.new)?\s*(do|\{)\s*(\|([^\|]*)\|\s*)?)/m
            raw = raw_code
            frag1, frag2 = [(0 .. (@line - 2)), (@line.pred .. -1)].map{|r| raw[r].join }
            match, type = frag2.match(regexp)[1..2]
            marker = (match =~ /\n\s*$/ ? "#{match.sub(/\n\s*$/,'')} %s \n" : "#{match} %s " ) %
              '__serializable_proc_marker__(__LINE__);'

            if raw[@line.pred].split(type).size > 2
              raise CannotInitializeError.new \
                "Static code analysis can only handle single occurrence of '#{type}' per line !!"
            else
              [
                RUBY_PARSER.parse(frag1 + escape_magic_vars(frag2).sub(match, marker)).inspect,
                marker
              ]
            end
          end

          def escape_magic_vars(s)
            %w{__FILE__ __LINE__}.inject(s){|s, var| s.gsub(var, "%|((#{var}))|") }
          end

          def unescape_magic_vars(s)
            %w{__FILE__ __LINE__}.inject(s){|s, var| s.gsub(%|"((#{var}))"|, var) }
          end

          def raw_code
            File.readlines(@file)
          end

      end
    end
  end
end

