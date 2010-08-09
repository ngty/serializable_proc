require 'rubygems'
require 'bacon'

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
            s_proc.code.should.equal(code)
            s_proc.file.should.equal(file)
            s_proc.line.should.equal(line.succ)
          end
        end
      end

      def having_expected_attrs(file, line, code)
        lambda do |s_proc|
          s_proc.code.should.equal(code)
          s_proc.file.should.equal(file)
          s_proc.line.should.equal(line)
        end
      end

    end
  end
end
