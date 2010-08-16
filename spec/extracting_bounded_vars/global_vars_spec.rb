require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting global vars' do

  extend SerializableProc::Spec::Helpers

  should 'handle outer-scoped ones w @@_isolate_vars including :global' do
    $x, $y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_isolate_vars = :global
        $x + $y
      }, {:gvar_x => $x, :gvar_y => $y}
  end

  should "handle inner-scoped ones w @@_isolate_vars including :global" do
    $x, $y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_isolate_vars = :global
        $z = 'wonder'
        %w{a b}.each{ puts $z, $x, $y }
      }, {:gvar_x => $x, :gvar_y => $y, :gvar_z => nil}
  end

  should 'not handle outer-scoped ones w @@_isolate_vars not including :global' do
    $x, $y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = nil;
        $x + $y
      }
  end

  should "not handle inner-scoped ones w @@_isolate_vars not including :global" do
    $x, $y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_isolate_vars = nil;
        $z = 'wonder'
        %w{a b}.each{ puts $z, $x, $y }
      }
  end

  should 'handle outer-scoped ones w @@_isolate_vars unspecified' do
    $x, $y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new { $x + $y }, {:gvar_x => $x, :gvar_y => $y}
  end

  should "handle inner-scoped ones w @@_isolate_vars unspecified" do
    $x, $y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        $z = 'wonder'
        %w{a b}.each{ puts $z, $x, $y }
      }, {:gvar_x => $x, :gvar_y => $y, :gvar_z => nil}
  end

end
