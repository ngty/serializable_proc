require 'rubygems'
require 'ruby_parser'
require 'ruby2ruby'

class SerializableProc

  RUBY_PARSER = RubyParser.new
  RUBY_2_RUBY = Ruby2Ruby.new

  attr_reader :file, :line, :code

  def initialize(&block)
    @block = block
    extract_file_and_line_and_code
  end

  def marshal_dump
    [@code, @file, @line]
  end

  def marshal_load(data)
    @code, @file, @line = data
  end

  private

    def eval!
      eval(@code, nil, @file, @line)
    end

    def extract_file_and_line_and_code
      code, remaining = code_fragments

      while frag = remaining[frag_regexp,1]
        begin
          sexp = RUBY_PARSER.parse(replace_magic_vars(code += frag))
          if sexp.inspect =~ sexp_regexp
            @code = revert_magic_vars(RUBY_2_RUBY.process(sexp)).sub('proc {','lambda {')
            break
          end
        rescue SyntaxError, Racc::ParseError, NoMethodError
          remaining.sub!(frag,'')
        end
      end
    end

    def code_fragments
      ignore, start_marker, arg =
        [:ignore, :start_marker, :arg].map{|key| code_match_args[key] }
      [
        arg ? "proc #{start_marker} |#{arg}|" : "proc #{start_marker}",
        source_code.sub(ignore, '')
      ]
    end

    def sexp_regexp
      @sexp_regexp ||= (
        Regexp.new([
          Regexp.quote("s(:iter, s(:call, nil, :"),
          "(proc|lambda)",
          Regexp.quote(", s(:arglist)), "),
          '(%s|%s|%s)' % [
            Regexp.quote('s(:masgn, s(:array, s('),
            Regexp.quote('s(:lasgn, :'),
            Regexp.quote('nil, s(')
          ]
        ].join)
      )
    end

    def frag_regexp
      @frag_regexp ||= (
        end_marker = {'do' => 'end', '{' => '\}'}[code_match_args[:start_marker]]
        /^(.*?\W#{end_marker})/m
      )
    end

    def code_regexp
      @code_regexp ||=
        /^(.*?(SerializableProc\.new|lambda|proc|Proc\.new)?\s*(do|\{)\s*(\|(.*?)\|\s*)?)/m
    end

    def code_match_args
      @code_match_args ||= (
        args = source_code.match(code_regexp)
        {
          :ignore => args[1],
          :start_marker => args[3],
          :arg => args[5]
        }
      )
    end

    def source_code
      @source_code ||= (
        file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(@block.inspect)[1..2]
        @file = File.expand_path(file)
        @line = line.to_i
        File.readlines(@file)[@line.pred .. -1].join
      )
    end

    def replace_magic_vars(code)
      %w{__FILE__ __LINE__}.inject(code) do |code, var|
        code.gsub(var, "%|((#{var}))|")
      end
    end

    def revert_magic_vars(code)
      %w{__FILE__ __LINE__}.inject(code) do |code, var|
        code.gsub(%|"((#{var}))"|, var)
      end
    end

end
