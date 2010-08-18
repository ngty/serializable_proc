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
                return sexp_derivatives(sexp)
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
            line = @line
            begin
              raw_sexp_and_marker_by_lineno(@line = line)
            rescue CannotAnalyseCodeError
              if RUBY_PLATFORM =~ /java/i
                line += 1
                retry
              else
                raise $!
              end
            end
          end

          def raw_sexp_and_marker_by_lineno(lineno)
            # TODO: Ugly chunk, need some lovely cleanup !!
            (%W{#{@klass}\.new lambda|proc|Proc\.new} + matchers).each do |declarative|
              regexp = /^((.*?)(#{declarative})(\s*(?:do|\{)\s*(?:\|(?:[^\|]*)\|\s*)?)(.*)?)$/m
              raw = raw_code
              lines1, lines2 = [(0 .. (lineno - 2)), (lineno.pred .. -1)].map{|r| raw[r] }
              prepend, type, block_start, append = lines2[0].match(regexp)[2..5] rescue next

              if lines2[0] =~ /^(.*?\W)?(#{declarative})(\W.*?\W(#{declarative}))+(\W.*)?$/
                msg = "Static code analysis can only handle single occurrence of '%s' per line !!" %
                  declarative.split('|').join("'/'")
                raise CannotAnalyseCodeError.new(msg)
              elsif lines2[0] =~ /^(.*?\W)?(#{declarative})(\W.*)?$/
                marker = "__serializable_proc_marker_#{lineno}__"
                line = "#{prepend}proc#{block_start} #{marker}; #{append}"
                lines = lines1.join + line + lines2[1..-1].join
                return [RUBY_PARSER.parse(lines, @file).inspect, marker]
              end
            end
            raise CannotAnalyseCodeError.new('Cannot find specified initializer !!')
          end

          def raw_code
            File.readlines(@file)
          end

      end
    end
  end
end

