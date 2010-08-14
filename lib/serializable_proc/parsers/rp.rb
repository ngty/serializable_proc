class SerializableProc

  class CannotAnalyseCodeError < Exception ; end

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
            sexp_str, remaining, type = extract_sexp_args
            while frag = remaining[/^([^\)]*\))/,1]
              begin
                sexp = eval(sexp_str += frag) # this throws SyntaxError if sexp is invalid
                code = unescape_magic_vars(RUBY_2_RUBY.process(Sandboxer.fsexp(sexp))).
                  sub(/__serializable_proc_marker__\(\d+\)\s*;?\s*\n?/m,'').sub(type,'lambda')
                return [code, sexp]
              rescue SyntaxError
                remaining.sub!(frag,'')
              end
            end
          end

          def extract_sexp_args
            raw, type, marker = raw_sexp_and_marker
            rq = lambda{|s| Regexp.quote(s) }
            regexp = Regexp.new([
              '^(.*(', (
                case type
                when /(#{@klass}|Proc)/ then rq["s(:iter, s(:call, s(:const, :#{$1}), :new, s(:arglist)),"]
                else rq['s(:iter, s(:call, nil, :'] + '(?:proc|lambda)' + rq[', s(:arglist']
                end
              ),
              '.*?',
              rq["s(:call, nil, :__serializable_proc_marker__, s(:arglist, s(:lit, #{@line})))"],
              '))(.*)$'
            ].join, Regexp::MULTILINE)
            [raw.match(regexp)[2..3], type].flatten
          end

          def raw_sexp_and_marker
            %W{#{@klass}\.new lambda|proc|Proc\.new}.each do |declarative|
              regexp = /^(.*?(#{declarative})?\s*(do|\{)\s*(\|([^\|]*)\|\s*)?)/m
              raw = raw_code
              frag1, frag2 = [(0 .. (@line - 2)), (@line.pred .. -1)].map{|r| raw[r].join }
              match, type = frag2.match(regexp)[1..2]
              next unless type
              marker = (match =~ /\n\s*$/ ? "#{match.sub(/\n\s*$/,'')} %s \n" : "#{match} %s " ) %
                '__serializable_proc_marker__(__LINE__);'

              splits = raw[@line.pred].split(/(#{declarative})/).reject{|f| f =~ /^(#{declarative})$/ }
              if splits.size > 2 and !splits.any?{|f| f =~ /\w+$/ }
                msg = "Static code analysis can only handle single occurrence of '%s' per line !!" %
                  declarative.split('|').join("'/'")
                raise CannotAnalyseCodeError.new(msg)
              else
                return [
                  RUBY_PARSER.parse(frag1 + escape_magic_vars(frag2).sub(match, marker)).inspect,
                  type, marker
                ]
              end
            end
            raise CannotAnalyseCodeError.new('Cannot find specified initializer !!')
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

