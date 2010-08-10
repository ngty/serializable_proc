require 'rubygems'
require 'forwardable'
require 'ruby2ruby'
require 'ruby_parser'

class SerializableProc

  class InvalidUsageError   < Exception ; end
  class NotImplementedError < Exception ; end

  RUBY_PARSER = RubyParser.new
  RUBY_2_RUBY = Ruby2Ruby.new

  extend Forwardable
  %w{line file code}.each{|meth| def_delegator :@proc, meth.to_sym }

  attr_reader :contexts

  def initialize(&block)
    @proc = ProcLike.new(block)
    @contexts = Context.new(@proc.sexp, block.binding).hash
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

    class Context

      attr_reader :hash

      def initialize(sexp, binding)
        @hash, _sexp = {}, sexp.dup
        while m = _sexp.match(/^(.*?s\(:(l|g|c|i)var, :([^\)]+)\))/)
          ignore, type, var = m[1..3]
          _sexp.sub!(ignore,'')
          append(var, (eval(var, binding) rescue nil))
        end
      end

      private

        def append(var, val)
          @hash.update(var.to_sym => Marshal.load(Marshal.dump(val)))
        end

    end

    class ProcLike

      attr_reader :file, :line, :code, :sexp

      def initialize(block)
        file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
        @file, @line = File.expand_path(file), line.to_i
        initialize_code_and_sexp rescue raise(InvalidUsageError)
      end

      private

        def initialize_code_and_sexp
          sexp, remaining = extract_sexp_args
          while frag = remaining[/^([^\)]*\))/,1]
            begin
              @sexp, @code = [
                sexp, unescape_magic_vars(
                  RUBY_2_RUBY.process(eval(sexp += frag)).
                    sub(/(SerializableProc\.new|Proc\.new|proc)/m,'lambda').
                    sub(/__serializable_proc_marker__\(\d+\)\s*;?\s*\n?/m,'')
                )
              ]
            rescue SyntaxError
              remaining.sub!(frag,'')
            end
          end
        end

        def extract_sexp_args
          raw, marker = raw_sexp_and_marker
          regexp = Regexp.new([
            '^(.*(',
            Regexp.quote(
              case marker
              when /(SerializableProc|Proc)/ then "s(:iter, s(:call, s(:const, :#{$1}), :new, s(:arglist)),"
              when /(proc|lambda)/ then "s(:iter, s(:call, nil, :#{$1}, s(:arglist"
              end
            ), '.*?',
            Regexp.quote("s(:call, nil, :__serializable_proc_marker__, s(:arglist, s(:lit, #{line})))"),
            '))(.*)$'
          ].join, Regexp::MULTILINE)
          raw.match(regexp)[2..3]
        end

        def raw_sexp_and_marker
          regexp = /^(.*?(SerializableProc\.new|lambda|proc|Proc\.new)?\s*(do|\{)\s*(\|([^\|]*)\|\s*)?)/m
          raw = raw_code
          frag1, frag2 = [(0 .. (line - 2)), (line.pred .. -1)].map{|r| raw[r].join }
          match = frag2.match(regexp)[1]
          marker = (match =~ /\n\s*$/ ? "#{match.sub(/\n\s*$/,'')} %s \n" : "#{match} %s " ) %
            '__serializable_proc_marker__(__LINE__);'
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
