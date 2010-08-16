require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Extracting bound variables' do

  class << self
    def m1    ; 'm1' ; end
    def m2(x) ; 'm2(%s)' % x ; end
  end

  describe '>> extracting local variables' do

    extend SerializableProc::Spec::Helpers

    should "handle outer-scoped ones" do
      x, y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new{ x + y }, {:lvar_x => x, :lvar_y => y}
    end

    should "handle inner-scoped ones" do
      x, y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new{|x| z = 'wonder' ; %w{a b}.each{|y| puts z, x, y } },
        {:lvar_x => x, :lvar_y => y, :lvar_z => nil}
    end

    # NOTE: Errors checking are found under ./initializing_errors_spec.rb

  end

  describe '>> extracting instance variables' do

    extend SerializableProc::Spec::Helpers

    should 'handle outer-scoped ones' do
      @x, @y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new{ @x + @y }, {:ivar_x => @x, :ivar_y => @y}
    end

    should "handle inner-scoped ones" do
      @x, @y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new{ @z = 'wonder' ; %w{a b}.each{ puts @z, @x, @y } },
        {:ivar_x => @x, :ivar_y => @y, :ivar_z => nil}
    end

    # NOTE: Errors checking are found under ./initializing_errors_spec.rb

  end

  describe '>> extracting class variables' do

    extend SerializableProc::Spec::Helpers

    should 'handle outer-scoped ones' do
      @@x, @@y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new{ @@x + @@y }, {:cvar_x => @@x, :cvar_y => @@y}
    end

    should "handle inner-scoped ones" do
      @@x, @@y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new{ @@z = 'wonder' ; %w{a b}.each{ puts @@z, @@x, @@y } },
        {:cvar_x => @@x, :cvar_y => @@y, :cvar_z => nil}
    end

    # NOTE: Errors checking are found under ./initializing_errors_spec.rb

  end

  describe '>> extracting global variables' do

    extend SerializableProc::Spec::Helpers

    should 'handle outer-scoped ones when @@_isolate_globals is true' do
      $x, $y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new {
          @@_isolate_globals = true
          $x + $y
        }, {:gvar_x => $x, :gvar_y => $y}
    end

    should "handle inner-scoped ones when @@_isolate_globals is true" do
      $x, $y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new {
          @@_isolate_globals = true
          $z = 'wonder'
          %w{a b}.each{ puts $z, $x, $y }
        }, {:gvar_x => $x, :gvar_y => $y, :gvar_z => nil}
    end

    should 'not handle outer-scoped ones when @@_isolate_globals is false' do
      $x, $y = 'awe', 'some'
      should_have_empty_binding \
        SerializableProc.new {
          @@_isolate_globals = false;
          $x + $y
        }
    end

    should "not handle inner-scoped ones when @@_isolate_globals is false" do
      $x, $y = 'awe', 'some'
      should_have_empty_binding \
        SerializableProc.new {
          @@_isolate_globals = false;
          $z = 'wonder'
          %w{a b}.each{ puts $z, $x, $y }
        }
    end

    should 'not handle outer-scoped ones' do
      $x, $y = 'awe', 'some'
      should_have_empty_binding \
        SerializableProc.new { $x + $y }
    end

    should "not handle inner-scoped ones" do
      $x, $y = 'awe', 'some'
      should_have_empty_binding \
        SerializableProc.new {
          $z = 'wonder'
          %w{a b}.each{ puts $z, $x, $y }
        }
    end

    # NOTE: Errors checking are found under ./initializing_errors_spec.rb

  end

  describe '>> extracting method returns' do

    extend SerializableProc::Spec::Helpers

    should "not handle" do
      should_have_empty_binding \
        SerializableProc.new { m1 + m2(3) }
    end

  end

  describe '>> extracting block-scoped variables' do

    extend SerializableProc::Spec::Helpers

    should "not handle local variables" do
      x = 'ox'
      should_have_empty_binding \
        SerializableProc.new { def test ; x = 'lx' ; end }
    end

    should "not handle instance variables" do
      @x = 'ox'
      should_have_empty_binding \
        SerializableProc.new { def test ; @x = 'ix' ; end }
    end

    should "not handle class variables" do
      @@x = 'ox'
      should_have_empty_binding \
        SerializableProc.new { def test ; @@x = 'cx' ; end }
    end

    should "not handle global variables" do
      $x = 'ox'
      should_have_empty_binding \
        SerializableProc.new { def test ; $x = 'gx' ; end }
    end

    should "not handle global variables when @@_isolate_globals is true" do
      $x = 'ox'
      should_have_empty_binding \
        SerializableProc.new {
          @@_isolate_globals = true
          def test ; $x = 'gx' ; end
        }
    end

    should "not handle global variables when @@_isolate_globals is false" do
      $x = 'ox'
      should_have_empty_binding \
        SerializableProc.new {
          @@_isolate_globals = false
          def test ; $x = 'gx' ; end
        }
    end

  end
end
