require 'rubygems'
require 'bacon'
require 'tempfile'
require 'ruby_parser'
require 'ruby2ruby'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'serializable_proc'

Bacon.summary_on_exit

class SerializableProc
  module Spec

    module Matchers

      def having_same_semantics_as(code2)
        normalize = lambda {|code| Ruby2Ruby.new.process(RubyParser.new.parse(code2)) }
        lambda {|code1| normalize[code1].should.equal(normalize[code2]) }
      end

      def same_object_as(o2)
        lambda {|o1| o1.object_id == o2.object_id }
      end

      def having_expected_attrs(file, line, code)
        lambda do |s_proc|
          s_proc.code.should.be having_same_semantics_as(code)
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
        s_proc.contexts.should.equal(expected)
        expected.each do |key, val|
          (s_proc.contexts[key].should.not.be same_object_as(val)) if val
        end
      end

      def should_handle_proc_variable(file, code, test_args)
        test_args.each do |line, block|
          should "handle proc variable [##{line}]" do
            s_proc = SerializableProc.new(&block)
            s_proc.code.should.be having_same_semantics_as(code)
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
