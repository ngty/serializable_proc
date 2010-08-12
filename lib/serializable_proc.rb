require 'rubygems'
require 'forwardable'
require 'ruby2ruby'

begin
  require 'parse_tree'
  require 'parse_tree_extensions'
rescue LoadError
  require 'ruby_parser'
end

class SerializableProc

  class GemNotInstalledError         < Exception ; end
  class CannotInitializeError        < Exception ; end
  class CannotSerializeVariableError < Exception ; end

  def initialize(&block)
    file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
    @file, @line = File.expand_path(file), line.to_i
    @code, sexp = Parsers::PT.process(block) || Parsers::RP.process(self.class, @file, @line)
    @binding = Binding.new(sexp.inspect, block.binding)
  end

  def ==(other)
    other.object_id == object_id or
      other.is_a?(self.class) && other.to_s == to_s
  end

  def to_proc
    eval(@code, binding, @file, @line)
  end

  def to_s
    @code
  end

  def call(*args)
    to_proc.call(*args)
  end

  alias_method :[], :call

  def binding
    @binding.eval!
  end

  def marshal_dump
    [@file, @line, @code, @binding]
  end

  def marshal_load(data)
    @file, @line, @code, @binding = data
  end

  private

    def eval!
      @proc ||= eval(@code, binding, @file, @line)
    end

    class Binding #:nodoc#

      def initialize(sexp_str, binding)
        @hash = {}
        while m = sexp_str.match(/^(.*?s\(:(?:l|g|c|i)var, :([^\)]+)\))/)
          ignore, var = m[1..2]
          sexp_str.sub!(ignore,'')
          begin
            val = binding.eval(var) rescue nil
            @hash.update(var.to_sym => mclone(val))
          rescue TypeError
            raise CannotSerializeVariableError.new("Variable #{var} cannot be serialized !!")
          end
        end
      end

      def eval!
        @binding ||= begin
          backup_globals
          set_vars = @hash.map{|(k,v)| "#{k} = Marshal.load(%|#{mdump(v)}|)" } * '; '
          (binding = Kernel.binding).eval(set_vars) ; binding
        ensure
          restore_globals
        end
      end

      def marshal_dump
        @hash
      end

      def marshal_load(data)
        @hash = data
      end

      private

        def backup_globals
          @hash.each do |var, val|
            if var.to_s =~ /^\$/
              (@globals_backup ||= {}).update(var => (eval(var.to_s) rescue nil))
              eval("#{var} = Marshal.load(%|#{mdump(val)}|)")
            end
          end
        end

        def restore_globals
          (@globals_backup ||= {}).each do |global, val|
            eval("#{global} = Marshal.load(%|#{mdump(val)}|)")
          end
          @globals_backup = nil
        end

        def mdump(val)
          Marshal.dump(val).gsub('|','\|')
        end

        def mclone(val)
          Marshal.load(mdump(val))
        end

    end

    module Parsers #:nodoc:

      module PT #:nodoc:
        class << self
          def process(block)
            [block.to_ruby, block.to_sexp] if Object.const_defined?(:ParseTree)
          end
        end
      end

      module RP #:nodoc:
        class << self

          RUBY_2_RUBY = Ruby2Ruby.new

          def process(klass, file, line)
            const_set(:RUBY_PARSER, RubyParser.new) unless const_defined?(:RUBY_PARSER)
            @klass, @file, @line = klass, file, line
            extract_code_and_sexp
          end

          private

            def extract_code_and_sexp
              sexp, remaining = extract_sexp_args
              while frag = remaining[/^([^\)]*\))/,1]
                begin
                  return [
                    unescape_magic_vars(
                      RUBY_2_RUBY.process(eval(sexp += frag)).
                        sub(/(#{@klass}\.new|Proc\.new|proc)/,'lambda').
                        sub(/__serializable_(lambda|proc)_marker__\(\d+\)\s*;?\s*\n?/m,'')
                    ), eval(sexp)
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
