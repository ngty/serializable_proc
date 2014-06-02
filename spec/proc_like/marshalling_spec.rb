require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Marshalling' do

  describe '>> basic (wo contextual references)' do

    before do
      @proc = SerializableProc.new{ %w{a b}.map{|x| x } }
    end

    should 'be able to marshal' do
      Marshal.load(Marshal.dump(@proc))
      true.should.be.true # the above should execute wo error
    end

    should 'be able to resume proc behaviours' do
      Marshal.load(Marshal.dump(@proc)).call.should.equal(%w{a b})
    end

  end

  describe '>> with contextual references' do

    should 'handle local variables' do
      x, y, expected = 'awe', 'some', 'awesome'
      s_proc = SerializableProc.new{ x + y }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal(expected)
    end

    should 'handle local variables that marshal with "|" character' do
      class MarshallingTestClass
        attr_accessor :i
        def initialize
          @i = 31921
        end
      end

      testClass = MarshallingTestClass.new
      s_proc = SerializableProc.new{ testClass.i }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal(31921)
    end

    should 'handle instance variables' do
      @x, @y, expected = 'awe', 'some', 'awesome'
      s_proc = SerializableProc.new{ @x + @y }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal(expected)
    end

    should 'handle class variables' do
      @@x, @@y, expected = 'awe', 'some', 'awesome'
      s_proc = SerializableProc.new{ @@x + @@y }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal(expected)
    end

    should 'handle global variables' do
      $x, $y, expected = 'awe', 'some', 'awesome'
      s_proc = SerializableProc.new{ $x + $y }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal(expected)
    end

  end

end

