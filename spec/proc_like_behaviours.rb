require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Proc like behaviours' do

  describe '>> ==' do

    before do
      @proc = SerializableProc.new{ %w{a b}.map{|x| x } }
    end

    should 'return true if comparing to itself' do
      @proc.should.equal(@proc)
    end

    should 'return true if another SerializableProc has the same code' do
      SerializableProc.new{ %w{a b}.map{|x| x } }.should.equal(@proc)
    end

    should 'return false if another SerializableProc does not have the same code' do
      SerializableProc.new{ %w{b c}.map{|x| x } }.should.not.equal(@proc)
    end

  end

  describe '>> call (alias [])' do

    should 'return yield result given no arg' do
      s_proc = SerializableProc.new { %w{b c}.map{|x| x } }
      expected = %w{b c}
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'return yield result given arg' do
      s_proc = SerializableProc.new {|n| %w{b c}.map{|x| x * n } }
      expected = %w{bb cc}
      s_proc.call(2).should.equal(expected)
      s_proc[2].should.equal(expected)
    end

    should 'reflect bound local variable' do
      x, y = 'awe', 'some'
      s_proc = SerializableProc.new { x + y }
      expected = x + y
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'reflect bound instance variable' do
      @x, @y = 'awe', 'some'
      s_proc = SerializableProc.new { @x + @y }
      expected = @x + @y
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'reflect bound class variable' do
      @@x, @@y = 'awe', 'some'
      s_proc = SerializableProc.new { @@x + @@y }
      expected = @@x + @@y
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'reflect bound global variable' do
      $x, $y = 'awe', 'some'
      expected = $x + $y
      s_proc = SerializableProc.new { $x + $y }
      $x, $y = 'wonder', 'ful'
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'not affect any globals' do
      $x, $y = 'awe', 'some'
      s_proc = SerializableProc.new { $x + $y }
      $x, $y = 'wonder', 'ful'
      s_proc.call ; s_proc[]
      $x.should.equal('wonder')
      $y.should.equal('ful')

    end

  end

  describe '>> clone' do
    should 'return a serializable proc that yields +ve ==' do
      s_proc = SerializableProc.new { %w{b c}.map{|x| x } }
      clone = s_proc.clone
      clone.should.equal(s_proc)
      clone.object_id.should.not.equal(s_proc.object_id)
    end
  end

  describe '>> binding' do
    should 'raise SerializableProc::NotImplementedError' do
      lambda { SerializableProc.new { 'a' }.binding }.
        should.raise(SerializableProc::NotImplementedError)
    end
  end

  describe '>> to_proc' do
    should 'return a non-serializable proc' do
      o_proc = lambda { %w{b c}.map{|x| x } }
      s_proc = SerializableProc.new(&o_proc)
      n_proc = s_proc.to_proc
      s_proc.should.not == n_proc
      n_proc.class.should == Proc
      n_proc.call.should.equal(o_proc.call)
    end
  end

  describe '>> to_s' do
    extend SerializableProc::Spec::Helpers
    should 'return its code' do
      SerializableProc.new{ x }.to_s.should.be having_same_semantics_as('lambda { x }')
    end
  end

end
