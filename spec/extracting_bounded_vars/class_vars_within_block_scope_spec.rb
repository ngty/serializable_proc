require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting class vars within block scope' do

  extend SerializableProc::Spec::Helpers

  should "not handle w @@_isolate_vars unspecified" do
    @@x = 'ox'
    should_have_empty_binding \
      SerializableProc.new { def test ; @@x = 'cx' ; end }
  end

  should "not handle w @@_isolate_vars including :class" do
    @@x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = :class
        def test ; @@x = 'cx' ; end
      }
  end

  should "not handle w @@_isolate_vars not including :class" do
    @@x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = nil
        def test ; @@x = 'cx' ; end
      }
  end

end
