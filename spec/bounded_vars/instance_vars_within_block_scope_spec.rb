require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting instance vars within block scope' do

  extend SerializableProc::Spec::Helpers

  should "not handle w @@_not_isolated_vars unspecified" do
    @x = 'ox'
    should_have_empty_binding \
      SerializableProc.new { def test ; @x = 'ix' ; end }
  end

  should "not handle if @@_not_isolated_vars includes :instance" do
    @x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :instance
        def test ; @x = 'ix' ; end
      }
  end

  should "not handle if @@_not_isolated_vars excludes :instance" do
    @x = 'ox'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = nil
        def test ; @x = 'ix' ; end
      }
  end

end
