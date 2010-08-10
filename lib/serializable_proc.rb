require 'rubygems'
require 'forwardable'
require 'ruby2ruby'
require 'ruby_parser'

class SerializableProc

  class NotImplementedError          < Exception ; end
  class CannotInitializeError        < Exception ; end
  class CannotSerializeVariableError < Exception ; end

  extend Forwardable
  %w{line file code}.each{|meth| def_delegator :@proc, meth.to_sym }

  attr_reader :contexts

  def initialize(&block)
    @proc = Proc.new(block)
    @contexts = Contexts.new(@proc.sexp, block.binding).hash
  end

  def ==(other)
    other.object_id == object_id or
      other.is_a?(SerializableProc) && other.code == code
  end

  def call(*args)
    to_proc.call(*args)
  end

  def to_proc
    eval(code, nil, file, line)
  end

  def binding
    raise NotImplementedError
  end

  alias_method :[], :call
  alias_method :to_s, :code

  private

    class Contexts

      attr_reader :hash

      def initialize(sexp, binding)
        @hash, _sexp = {}, sexp.dup
        while m = _sexp.match(/^(.*?s\(:(l|g|c|i)var, :([^\)]+)\))/)
          ignore, type, var = m[1..3]
          _sexp.sub!(ignore,'')
          append(var, (binding.eval(var) rescue nil))
        end
      end

      private

        def append(var, val)
          begin
            @hash.update(var.to_sym => Marshal.load(Marshal.dump(val)))
          rescue TypeError
            raise CannotSerializeVariableError.new("Variable #{var} cannot be serialized !!")
          end
        end

    end

    class Proc

      RUBY_PARSER = RubyParser.new
      RUBY_2_RUBY = Ruby2Ruby.new

      attr_reader :file, :line, :code, :sexp

      def initialize(block)
        file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
        @file, @line = File.expand_path(file), line.to_i
        initialize_code_and_sexp
      end

      private

        def initialize_code_and_sexp
          sexp, remaining = extract_sexp_args
          while frag = remaining[/^([^\)]*\))/,1]
            begin
              @sexp, @code = [
                sexp, unescape_magic_vars(
                  RUBY_2_RUBY.process(eval(sexp += frag)).
                    sub(/(SerializableProc\.new|Proc\.new|proc)/,'lambda').
                    sub(/__serializable_(lambda|proc)_marker__\(\d+\)\s*;?\s*\n?/m,'')
                )
              ]
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
              when /(SerializableProc|Proc)/ then rq["s(:iter, s(:call, s(:const, :#{$1}), :new, s(:arglist)),"]
              else rq['s(:iter, s(:call, nil, :'] + '(?:proc|lambda)' + rq[', s(:arglist']
              end
            ),
            '.*?',
            rq["s(:call, nil, :__serializable_proc_marker__, s(:arglist, s(:lit, #{line})))"],
            '))(.*)$'
          ].join, Regexp::MULTILINE)
          raw.match(regexp)[2..3]
        end

        def raw_sexp_and_marker
          regexp = /^(.*?(SerializableProc\.new|lambda|proc|Proc\.new)?\s*(do|\{)\s*(\|([^\|]*)\|\s*)?)/m
          raw = raw_code
          frag1, frag2 = [(0 .. (line - 2)), (line.pred .. -1)].map{|r| raw[r].join }
          match, type = frag2.match(regexp)[1..2]
          marker = (match =~ /\n\s*$/ ? "#{match.sub(/\n\s*$/,'')} %s \n" : "#{match} %s " ) %
            '__serializable_proc_marker__(__LINE__);'

          if raw[line.pred].split(type).size > 2
            raise CannotInitializeError.new \
              "Static code analysis can only handle single occurrence of '#{type}' per line !!"
          end

          [
            RUBY_PARSER.parse(frag1 + escape_magic_vars(frag2).sub(match, marker)).inspect,
            marker
          ]
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
