require 'rubygems'
require 'bacon'
require 'tempfile'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'serializable_proc'

Bacon.summary_on_exit

class SerializableProc

  attr_reader :proc, :contexts
  class Proc ; attr_reader :file, :code, :line ; end
  class Contexts ; attr_reader :hash ; end

  module Spec

    module Matchers

      def having_same_semantics_as(code2)
        normalize = lambda {|code| Ruby2Ruby.new.process(RubyParser.new.parse(code2)) }
        lambda {|code1| normalize[code1].should.equal(normalize[code2]) }
      end

      def same_object_as(o2)
        lambda {|o1| o1.object_id == o2.object_id }
      end

      def having_expected_proc_attrs(file, line, code)
        lambda do |s_proc|
          base_proc = s_proc.proc
          base_proc.code.should.be having_same_semantics_as(code)
          base_proc.file.should.equal(file)
          base_proc.line.should.equal(line)
        end
      end

      def raising_cannot_serialize_variable_error(var)
        lambda do |block|
          block.should.raise(SerializableProc::CannotSerializeVariableError).
            message.should.equal('Variable %s cannot be serialized !!' % var)
          true
        end
      end

      def raising_cannot_initialize_error(name)
        lambda do |block|
          block.should.raise(SerializableProc::CannotInitializeError).message.should.
          equal("Static code analysis can only handle single occurrence of '#{name}' per line !!")
          true
        end
      end

    end

    module Macros

      def should_have_expected_contexts(s_proc, expected)
        s_proc.contexts.hash.should.equal(expected)
        expected.each do |key, val|
          (s_proc.contexts.hash[key].should.not.be same_object_as(val)) if val
        end
      end

      def should_handle_proc_variable(file, code, test_args)
        test_args.each do |line, block|
          should "handle proc variable [##{line}]" do
            base_proc = SerializableProc.new(&block).proc
            base_proc.code.should.be having_same_semantics_as(code)
            base_proc.file.should.equal(file)
            base_proc.line.should.equal(line.succ)
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
