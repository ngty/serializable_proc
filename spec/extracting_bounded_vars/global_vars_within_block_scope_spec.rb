require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting global vars within block scope' do

  extend SerializableProc::Spec::Helpers

  should "not handle w @@_isolate_vars unspecified" do
    $x = 'ox'
    should_have_empty_binding \
      SerializableProc.new { def test ; $x = 'gx' ; end }
  end

  should "not handle w @@_isolate_vars including :global" do
    $x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = :global
        def test ; $x = 'gx' ; end
      }
  end

  should "not handle w @@_isolate_vars not including :global" do
    $x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = nil
        def test ; $x = 'gx' ; end
      }
  end

end
