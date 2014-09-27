require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Isolating variables (new syntax)' do

  extend SerializableProc::Spec::Helpers

  should 'isolate all vars if isolation not specified' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new {
        [x, @x, @@x, $x]
      }, {:lvar_x => x, :ivar_x => @x, :cvar_x => @@x, :gvar_x => $x}
  end

  should 'isolate no vars if isolate is []' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(isolate: []) {
        [x, @x, @@x, $x]
      }, {}
  end

  should 'isolate all vars if isolate: :all' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(isolate: :all) {
        [x, @x, @@x, $x]
      }, {:lvar_x => x, :ivar_x => @x, :cvar_x => @@x, :gvar_x => $x}
  end

  should 'isolate all vars if isolate: [:all]' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(isolate: [:all]) {
        [x, @x, @@x, $x]
      }, {:lvar_x => x, :ivar_x => @x, :cvar_x => @@x, :gvar_x => $x}
  end

  should 'ignore no vars if ignore: :all' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(ignore: :all) {
        [x, @x, @@x, $x]
      }, {}
  end

  should 'isolate locals if isolate: :all and ignore: all except locals' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(isolate: :all, ignore: [:global, :class, :instance]) {
        [x, @x, @@x, $x]
      }, {:lvar_x => x}
  end

  should 'isolate no vars if ignore same as isolate (ignore overrides isolate)' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(isolate: :local, ignore: :local) {
        [x, @x, @@x, $x]
      }, {}
  end

  should 'isolate all except for the ones specified in ignore if isolate not specified' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(ignore: :local) {
        [x, @x, @@x, $x]
      }, {:ivar_x => @x, :cvar_x => @@x, :gvar_x => $x}
  end

  should 'use @not_isolated_vars in case @ignore not specified' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(isolate: :all) {
        @@_not_isolated_vars = :local, :global
        [x, @x, @@x, $x]
      }, {:ivar_x => @x, :cvar_x => @@x}
  end

  should 'use @ignore over @not_isolated_vars in case @ignore is specified' do
    x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    should_have_expected_binding \
      SerializableProc.new(isolate: :all, ignore: :local) {
        @@_not_isolated_vars = :local, :global
        [x, @x, @@x, $x]
      }, {:ivar_x => @x, :cvar_x => @@x, :gvar_x => $x}
  end
end
