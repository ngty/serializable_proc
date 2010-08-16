require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting class vars within block scope' do

  extend SerializableProc::Spec::Helpers

  should "not handle w @@_not_isolated_vars unspecified" do
    @@x = 'ox'
    should_have_empty_binding \
      SerializableProc.new { def test ; @@x = 'cx' ; end }
  end

  should "not handle if @@_not_isolated_vars includes :class" do
    @@x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :class
        def test ; @@x = 'cx' ; end
      }
  end

  should "not handle if @@_not_isolated_vars excludes :class" do
    @@x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = nil
        def test ; @@x = 'cx' ; end
      }
  end

end
