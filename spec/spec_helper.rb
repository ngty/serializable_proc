require 'rubygems'
require 'bacon'
require 'ruby_parser'
require 'ruby2ruby'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'serializable_proc'

Bacon.summary_on_exit

class SerializableProc
  module Spec
    module Macros

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

      def having_expected_attrs(file, line, code)
        lambda do |s_proc|
          s_proc.code.should.be having_same_semantics_as(code)
          s_proc.file.should.equal(file)
          s_proc.line.should.equal(line)
        end
      end

      def having_same_semantics_as(code2)
        normalize = lambda {|code| Ruby2Ruby.new.process(RubyParser.new.parse(code2)) }
        lambda {|code1| normalize[code1].should.equal(normalize[code2]) }
      end

    end
  end
end
