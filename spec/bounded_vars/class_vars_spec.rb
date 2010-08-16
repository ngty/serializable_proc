require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting class vars' do

  extend SerializableProc::Spec::Helpers

  should 'handle outer-scoped ones w @@_isolate_vars including :class' do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_isolate_vars = :class
        @@x + @@y
      }, {:cvar_x => @@x, :cvar_y => @@y}
  end

  should "handle inner-scoped ones w @@_isolate_vars including :class" do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_isolate_vars = :class
        @@z = 'wonder'
        %w{a b}.each{ puts @@z, @@x, @@y }
      }, {:cvar_x => @@x, :cvar_y => @@y, :cvar_z => nil}
  end

  should 'not handle outer-scoped ones w @@_isolate_vars not including :class' do
    @@x, @@y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = nil;
        @@x + @@y
      }
  end

  should "not handle inner-scoped ones w @@_isolate_vars not including :class" do
    @@x, @@y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = nil;
        @@z = 'wonder'
        %w{a b}.each{ puts @@z, @@x, @@y }
      }
  end

  should 'handle outer-scoped ones w @@_isolate_vars unspecified' do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new { @@x + @@y }, {:cvar_x => @@x, :cvar_y => @@y}
  end

  should "handle inner-scoped ones w @@_isolate_vars unspecified" do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@z = 'wonder'
        %w{a b}.each{ puts @@z, @@x, @@y }
      }, {:cvar_x => @@x, :cvar_y => @@y, :cvar_z => nil}
  end

end
