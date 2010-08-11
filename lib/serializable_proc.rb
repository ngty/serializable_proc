require 'rubygems'
require 'forwardable'

class SerializableProc

  class NotImplementedError          < Exception ; end
  class CannotInitializeError        < Exception ; end
  class CannotSerializeVariableError < Exception ; end
  class GemNotInstalledError         < Exception ; end

  extend Forwardable
  %w{== to_proc to_s}.each{|meth| def_delegator :@proc, meth.to_sym }

  def initialize(&block)
    @proc = Proc.new(block, self)
    @contexts = Contexts.new(@proc.to_sexp, block.binding)
  end

  def call(*args)
    @contexts.instance_exec(*args, &self)
  end

  def binding
    # TODO: No idea on what meaningful stuff to return (yet).
    raise NotImplementedError
  end

  alias_method :[], :call

  protected

    class Contexts #:nodoc#

      def initialize(sexp, binding)
        initialize_hash(sexp.inspect, binding)
      end

      def instance_exec(*args, &block)
        within_set_globals{ instance.instance_exec(*args, &block) }
      end

      private

        def instance
          @instance ||= (
            vars = {:c => /^@@/, :i => /^@[^@]/, :l => /^[^@\$]/}.
              inject({}){|memo, (t,r)| memo.merge(t => @hash.select{|k,v| k.to_s =~ r }) }
            object = Class.new {
              klass = RUBY_VERSION.include?('1.9') ? SerializableProc::Contexts : self
              vars[:l].each{|var, val| define_method(var){ val } }
              vars[:c].each{|var, val| klass.send(:class_variable_set, var, val) }
              define_method(:initialize){ vars[:i].each{|var, val| instance_variable_set(var, val) } }
            }.new
          )
        end

        def initialize_hash(sexp, binding)
          @hash = {}
          while m = sexp.match(/^(.*?s\(:(l|g|c|i)var, :([^\)]+)\))/)
            ignore, type, var = m[1..3]
            sexp.sub!(ignore,'')
            begin
              val = binding.eval(var) rescue nil
              @hash.update(var.to_sym => Marshal.load(Marshal.dump(val)))
            rescue TypeError
              raise CannotSerializeVariableError.new("Variable #{var} cannot be serialized !!")
            end
          end
        end

        def within_set_globals(&block)
          backup_globals
          yield ensure revert_globals
        end

        def backup_globals
          @hash.each do |var, val|
            if var.to_s =~ /^\$/
              (@globals_backup ||= {}).update(var => (eval(var.to_s) rescue nil))
              eval("#{var} = Marshal.load(%|#{Marshal.dump(val).gsub('|','\|')}|)")
            end
          end
        end

        def revert_globals
          (@globals_backup ||= {}).each do |global, val|
            eval("#{global} = Marshal.load(%|#{Marshal.dump(val).gsub('|','\|')}|)")
          end
          @globals_backup = nil
        end

    end

    class Proc #:nodoc#

      def initialize(block, owner)
        file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
        @klass, @file, @line = owner.class, File.expand_path(file), line.to_i
        @code, @sexp = ParseTree.process(block) || RubyParser.process(@klass, @file, @line)
      end

      def ==(other)
        other.object_id == object_id or
          other.is_a?(@klass) && other.to_s == to_s
      end

      def to_proc
        eval(@code, nil, @file, @line)
      end

      def to_s
        @code
      end

      def to_sexp
        @sexp
      end

    end

    class ParseTree #:nodoc:
      class << self
        def process(block)
          begin
            require 'parse_tree'
            require 'parse_tree_extensions'
            [block.to_ruby, block.to_sexp]
          rescue LoadError
            nil
          end
        end
      end
    end

    class RubyParser #:nodoc:
      class << self

        def process(klass, file, line)
          initialize_parser
          @klass, @file, @line = klass, file, line
          extract_code_and_sexp
        end

        private

          def initialize_parser
            begin
              self.class.instance_eval do
                require 'ruby_parser'
                require 'ruby2ruby'
                const_set(:RUBY_2_RUBY, ::Ruby2Ruby.new) unless const_defined?(:RUBY_2_RUBY)
                const_set(:RUBY_PARSER, ::RubyParser.new) unless const_defined?(:RUBY_PARSER)
              end
            rescue LoadError
              raise GemNotInstalledError.new \
                "SerializableProc requires ParseTree (faster) or RubyParser & Ruby2Ruby to work its magic !!"
            end
          end

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
