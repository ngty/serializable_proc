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
      should_have_expected_contexts SerializableProc.new{ x + y }, {:x => x, :y => y}
    end

    should "handle inner-scoped ones" do
      x, y = 'awe', 'some'
      should_have_expected_contexts \
        SerializableProc.new{|x| z = 'wonder' ; %w{a b}.each{|y| puts z, x, y } },
        {:x => x, :y => y, :z => nil}
    end

    should "raise SerializableProc::CannotSerializeVariableError if variable cannot be marshalled" do
      f = Tempfile.new('fake')
      lambda { SerializableProc.new{ f } }.should.be raising_cannot_serialize_variable_error('f')
    end

  end

  describe '>> extracting instance variables' do

    extend SerializableProc::Spec::Helpers

    should 'handle outer-scoped ones' do
      @x, @y = 'awe', 'some'
      should_have_expected_contexts SerializableProc.new{ @x + @y }, {:@x => @x, :@y => @y}
    end

    should "handle inner-scoped ones" do
      @x, @y = 'awe', 'some'
      should_have_expected_contexts \
        SerializableProc.new{|@x| @z = 'wonder' ; %w{a b}.each{|@y| puts @z, @x, @y } },
        {:@x => @x, :@y => @y, :@z => nil}
    end

    should "raise SerializableProc::CannotSerializeVariableError if variable cannot be marshalled" do
      @f = Tempfile.new('fake')
      lambda { SerializableProc.new{ @f } }.should.be raising_cannot_serialize_variable_error('@f')
    end

  end

  describe '>> extracting class variables' do

    extend SerializableProc::Spec::Helpers

    should 'handle outer-scoped ones' do
      @@x, @@y = 'awe', 'some'
      should_have_expected_contexts SerializableProc.new{ @@x + @@y }, {:@@x => @@x, :@@y => @@y}
    end

    should "handle inner-scoped ones" do
      @@x, @@y = 'awe', 'some'
      should_have_expected_contexts \
        SerializableProc.new{|@@x| @@z = 'wonder' ; %w{a b}.each{|@@y| puts @@z, @@x, @@y } },
        {:@@x => @@x, :@@y => @@y, :@@z => nil}
    end

    should "raise SerializableProc::CannotSerializeVariableError if variable cannot be marshalled" do
      @@f = Tempfile.new('fake')
      lambda { SerializableProc.new{ @@f } }.should.be raising_cannot_serialize_variable_error('@@f')
    end

  end

  describe '>> extracting global variables' do

    extend SerializableProc::Spec::Helpers

    should 'handle outer-scoped ones' do
      $x, $y = 'awe', 'some'
      should_have_expected_contexts SerializableProc.new{ $x + $y }, {:$x => $x, :$y => $y}
    end

    should "handle inner-scoped ones" do
      $x, $y = 'awe', 'some'
      should_have_expected_contexts \
        SerializableProc.new{|$x| $z = 'wonder' ; %w{a b}.each{|$y| puts $z, $x, $y } },
        {:$x => $x, :$y => $y, :$z => nil}
    end

    should "raise SerializableProc::CannotSerializeVariableError if variable cannot be marshalled" do
      $f = Tempfile.new('fake')
      lambda { SerializableProc.new{ $f } }.should.be raising_cannot_serialize_variable_error('$f')
    end

  end

  describe '>> extracting method returns' do
    should "not handle" do
      SerializableProc.new { m1 + m2(3) }.contexts.should.be.empty
    end
  end

end
