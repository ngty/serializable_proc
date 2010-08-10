require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Contextual references' do

  class << self
    def m1    ; 'm1' ; end
    def m2(x) ; 'm2(%s)' % x ; end
  end

  describe '>> assigning local variables' do

    extend SerializableProc::Spec::Matchers
    extend SerializableProc::Spec::Macros

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

    should "raise TypeError if variable cannot be marshalled" do
      f = Tempfile.new('fake')
      lambda { SerializableProc.new{ f } }.should.raise(TypeError)
    end

  end

  describe '>> assigning instance variables' do

    extend SerializableProc::Spec::Matchers
    extend SerializableProc::Spec::Macros

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

    should "raise TypeError if variable cannot be marshalled" do
      @f = Tempfile.new('fake')
      lambda { SerializableProc.new{ @f } }.should.raise(TypeError)
    end

  end

  describe '>> assigning class variables' do

    extend SerializableProc::Spec::Matchers
    extend SerializableProc::Spec::Macros

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

    should "raise TypeError if variable cannot be marshalled" do
      @@f = Tempfile.new('fake')
      lambda { SerializableProc.new{ @@f } }.should.raise(TypeError)
    end

  end

  describe '>> assigning global variables' do

    extend SerializableProc::Spec::Matchers
    extend SerializableProc::Spec::Macros

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

    should "raise TypeError if variable cannot be marshalled" do
      $f = Tempfile.new('fake')
      lambda { SerializableProc.new{ $f } }.should.raise(TypeError)
    end

  end

  describe '>> assigning method calls' do
    should "not handle" do
      SerializableProc.new { m1 + m2(3) }.contexts.should.be.empty
    end
  end

end
