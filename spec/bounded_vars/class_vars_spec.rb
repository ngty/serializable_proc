require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting class vars' do

  extend SerializableProc::Spec::Helpers

  should 'handle outer-scoped ones if @@_not_isolated_vars excludes :class' do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_not_isolated_vars = nil
        @@x + @@y
      }, {:cvar_x => @@x, :cvar_y => @@y}
  end

  should "handle inner-scoped ones if @@_not_isolated_vars excludes :class" do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_not_isolated_vars = nil
        @@z = 'wonder'
        %w{a b}.each{ puts @@z, @@x, @@y }
      }, {:cvar_x => @@x, :cvar_y => @@y, :cvar_z => nil}
  end

  should 'not handle outer-scoped ones if @@_not_isolated_vars includes :class' do
    @@x, @@y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :class;
        @@x + @@y
      }
  end

  should "not handle inner-scoped ones if @@_not_isolated_vars includes :class" do
    @@x, @@y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :class;
        @@z = 'wonder'
        %w{a b}.each{ puts @@z, @@x, @@y }
      }
  end

  should 'handle outer-scoped ones w @@_not_isolated_vars unspecified' do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new { @@x + @@y }, {:cvar_x => @@x, :cvar_y => @@y}
  end

  should "handle inner-scoped ones w @@_not_isolated_vars unspecified" do
    @@x, @@y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@z = 'wonder'
        %w{a b}.each{ puts @@z, @@x, @@y }
      }, {:cvar_x => @@x, :cvar_y => @@y, :cvar_z => nil}
  end

end
