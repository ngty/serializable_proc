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

    should 'handle local variables that marshal with "|"' do
      v = {a: '|'}
      s_proc = SerializableProc.new{ v[:a] }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal('|')
    end

    should 'handle local variables that marshal with "#{"' do
      v = {a: '#{'}
      s_proc = SerializableProc.new{ v[:a] }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal('#{')
    end

    should 'handle local variables that marshal with some non-friendly char' do
      require 'time'
      v = Time.parse('Mon, 16 Jun 2014 11:23:13')
      s_proc = SerializableProc.new{ v }
      Marshal.load(Marshal.dump(s_proc)).call.should.equal(v)
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

