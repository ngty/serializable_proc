require 'rubygems'
require 'forwardable'
require 'ruby2ruby'
require 'ruby_parser'

class SerializableProc

  class InvalidUsage < Exception ; end

  RUBY_PARSER = RubyParser.new
  RUBY_2_RUBY = Ruby2Ruby.new

  extend Forwardable
  %w{line file arity}.each{|meth| def_delegator :@proc, meth.to_sym }

  attr_reader :code, :context

  def initialize(&block)
    @proc = Proc.new(block)
    @code, sexp = extract_code_and_sexp
    # @context = Context.new(sexp, block.binding)
  end

  def ==(other)
    other.object_id == object_id or
      other.is_a?(SerializableProc) && other.code == code
  end

  def call(*args)
    to_proc.call(*args)
  end

  def to_proc
    eval(@code, nil, file, line)
  end

  alias_method :[], :call
  alias_method :to_s, :code

  private

    def extract_sexp_and_marker
      regexp = /^(.*?(SerializableProc\.new|lambda|proc|Proc\.new)?\s*(do|\{)\s*(\|([^\|]*)\|\s*)?)/m
      raw_code = @proc.raw_code
      frag1, frag2 = [(0 .. (@proc.line - 2)), (@proc.line.pred .. -1)].map{|r| raw_code[r].join }
      match = frag2.match(regexp)[1]
      marker = (match =~ /\n\s*$/ ? "#{match.sub(/\n\s*$/,'')} %s \n" : "#{match} %s " ) %
        '__serializable_proc_marker__(__LINE__);'
      [
        RubyParser.new.parse(frag1 + escape_magic_vars(frag2).sub(match, marker)).inspect,
        marker
      ]
    end

    def extract_code_and_sexp_args
      raw_sexp, marker = extract_sexp_and_marker
      regexp = Regexp.new([
        '^(.*(',
        Regexp.quote(
          case marker
          when /(SerializableProc|Proc)/ then "s(:iter, s(:call, s(:const, :#{$1}), :new, s(:arglist)),"
          when /(proc|lambda)/ then "s(:iter, s(:call, nil, :#{$1}, s(:arglist"
          else raise InvalidUsage
          end
        ), '.*?',
        Regexp.quote("s(:call, nil, :__serializable_proc_marker__, s(:arglist, s(:lit, #{@proc.line})))"),
        '))(.*)$'
      ].join, Regexp::MULTILINE)
      raw_sexp.match(regexp)[2..3]
    end

    def extract_code_and_sexp
      sexp, remaining = extract_code_and_sexp_args
      while frag = remaining[/^([^\)]*\))/,1]
        begin
          return [
            unescape_magic_vars(
              Ruby2Ruby.new.process(eval(sexp += frag)).
                sub(/(SerializableProc\.new|Proc\.new|proc)/m,'lambda').
                sub(/__serializable_proc_marker__\(\d+\)\s*;?\s*\n?/m,'')
            ), sexp
          ]
        rescue SyntaxError
          remaining.sub!(frag,'')
        end
      end
    end

    def escape_magic_vars(code)
      %w{__FILE__ __LINE__}.inject(code) do |code, var|
        code.gsub(var, "%|((#{var}))|")
      end
    end

    def unescape_magic_vars(code)
      %w{__FILE__ __LINE__}.inject(code) do |code, var|
        code.gsub(%|"((#{var}))"|, var)
      end
    end

    class Proc

      attr_reader :file, :line, :arity

      def initialize(block)
        file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
        @file, @line, @arity = File.expand_path(file), line.to_i, block.arity
      end

      def raw_code
        File.readlines(@file)
      end

    end

    class Context

      attr_reader :hash

      def initialize(sexp, binding)
        @hash = {}
        while m = sexp.match(/^(.*?s\(:call, nil, :([^,]+), s\(:arglist\)\))/)
          sexp.sub!(m[1],'')
          next if %w{lambda proc}.include?(m[2])
          key, val = m[2].to_sym, eval(m[2], binding)
          @hash.update(key => Marshal.load(Marshal.dump(val)))
        end
      end

    end

end
