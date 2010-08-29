require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting local vars within block scope' do

  extend SerializableProc::Spec::Helpers

  should "not handle w @@_not_isolated_vars unspecified" do
    x = 'ox'
    should_have_empty_binding \
      SerializableProc.new { def test ; x = 'lx' ; end }
  end

  should "not handle if @@_not_isolated_vars includes :local" do
    x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :local
        def test ; x = 'lx' ; end
      }
  end

  should "not handle if @@_not_isolated_vars includes :all" do
    x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :all
        def test ; x = 'lx' ; end
      }
  end

  should "not handle if @@_not_isolated_vars excludes :local" do
    x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = nil
        def test ; x = 'lx' ; end
      }
  end

end
