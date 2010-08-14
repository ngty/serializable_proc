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
            sexp_str, remaining, type, marker = extract_sexp_args
            while frag = remaining[/^([^\)]*\))/,1]
              begin
                sexp = eval(sexp_str += frag) # this throws SyntaxError if sexp is invalid
                code = unescape_magic_vars(RUBY_2_RUBY.process(Sandboxer.fsexp(sexp))).
                  sub(/#{marker}\s*;?/m,'').sub(type,'lambda')
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
              rq["s(:call, nil, :#{marker}, s(:arglist))"],
              '))(.*)$'
            ].join, Regexp::MULTILINE)
            [raw.match(regexp)[2..3], type, marker].flatten
          end


          def raw_sexp_and_marker
            %W{#{@klass}\.new lambda|proc|Proc\.new}.each do |declarative|
              regexp = /^(.*?(#{declarative})\s*(do|\{)\s*(\|([^\|]*)\|\s*)?)/
              raw = raw_code
              lines1, lines2 = [(0 .. (@line - 2)), (@line.pred .. -1)].map{|r| raw[r] }
              match, type = lines2[0].match(regexp)[1..2] rescue next

              if lines2[0] =~ /^(.*?\W)?(#{declarative})(\W.*?\W(#{declarative}))+(\W.*)?$/
                msg = "Static code analysis can only handle single occurrence of '%s' per line !!" %
                  declarative.split('|').join("'/'")
                raise CannotAnalyseCodeError.new(msg)
              elsif lines2[0] =~ /^(.*?\W)?(#{declarative})(\W.*)?$/
                marker = "__serializable_proc_marker_#{@line}__"
                lines = lines1.join + escape_magic_vars(lines2[0].sub(match, match+marker+';') + lines2[1..-1].join)
                return [RUBY_PARSER.parse(lines).inspect, type, marker]
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

