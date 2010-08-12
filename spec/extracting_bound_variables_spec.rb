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

    should 'handle outer-scoped ones' do
      $x, $y = 'awe', 'some'
      should_have_expected_binding SerializableProc.new{ $x + $y }, {:gvar_x => $x, :gvar_y => $y}
    end

    should "handle inner-scoped ones" do
      $x, $y = 'awe', 'some'
      should_have_expected_binding \
        SerializableProc.new{ $z = 'wonder' ; %w{a b}.each{ puts $z, $x, $y } },
        {:gvar_x => $x, :gvar_y => $y, :gvar_z => nil}
    end

    # NOTE: Errors checking are found under ./initializing_errors_spec.rb

  end

  describe '>> extracting method returns' do
    should "not handle" do
      SerializableProc.new { m1 + m2(3) }.binding_dump.should.be.empty
    end
  end

end
