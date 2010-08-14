require 'rubygems'
require 'bacon'
require 'tempfile'
require 'ruby2ruby'

$parse_tree_installed =
  begin
    require 'parse_tree'
    true
  rescue LoadError
    require 'ruby_parser'
    nil
  end

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'serializable_proc'

Bacon.summary_on_exit

class SerializableProc

  attr_reader :code, :file, :line

  def binding_dump
    @binding.instance_variable_get(:@vars)
  end

  module Spec

    module Matchers

      def having_same_semantics_as(code2)
        to_code = lambda{|sexp| ::Ruby2Ruby.new.process(sexp) }
        to_sexp = $parse_tree_installed ?
          lambda{|code| Unifier.new.process(::ParseTree.translate(code)) } :
          lambda{|code| ::RubyParser.new.parse(code) }
        normalize = lambda{|code| to_code[to_sexp[code]].sub('lambda','proc') }
        lambda {|code1| normalize[code1].should.equal(normalize[code2]) }
      end

      def same_object_as(o2)
        lambda {|o1| o1.object_id == o2.object_id }
      end

      def having_expected_proc_attrs(file, line, code)
        lambda do |s_proc|
          s_proc.code[:runnable].should.be having_same_semantics_as(code)
          s_proc.file.should.equal(file)
          s_proc.line.should.equal(line)
        end
      end

      def raising_cannot_serialize_variable_error(var)
        lambda do |block|
          block.should.raise(SerializableProc::CannotSerializeVariableError).
            message.should.equal('Variable %s cannot be serialized !!' % var)
          true
        end
      end

      def raising_cannot_analyse_error(descrp)
        lambda do |block|
          block.should.raise(SerializableProc::CannotAnalyseCodeError).message.should.
          equal("Static code analysis can only handle single occurrence of #{descrp} per line !!")
          true
        end
      end

    end

    module Macros

      def should_have_expected_binding(s_proc, expected)
        s_proc.binding_dump.should.equal(expected)
        expected.each do |key, val|
          (s_proc.binding_dump[key].should.not.be same_object_as(val)) if val
        end
      end

      def should_handle_proc_variable(file, code, test_args)
        test_args.each do |line, block|
          should "handle proc variable [##{line}]" do
            s_proc = SerializableProc.new(&block)
            s_proc.code[:runnable].should.be having_same_semantics_as(code)
            s_proc.file.should.equal(file)
            s_proc.line.should.equal(line.succ)
          end
        end
      end

    end

    module Helpers
      include Macros
      include Matchers
    end

  end
end
