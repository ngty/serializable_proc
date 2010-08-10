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

  describe '>> []' do

    should 'return yield result given no arg' do
      SerializableProc.new { %w{b c}.map{|x| x } }[].should.equal(%w{b c})
    end

    should 'return yield result given arg' do
      SerializableProc.new {|n| %w{b c}.map{|x| x * n } }[2].should.equal(%w{bb cc})
    end

  end

  describe '>> call' do

    should 'return yield result given no arg' do
      SerializableProc.new { %w{b c}.map{|x| x } }.call.should.equal(%w{b c})
    end

    should 'return yield result given arg' do
      SerializableProc.new {|n| %w{b c}.map{|x| x * n } }.call(2).should.equal(%w{bb cc})
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
    should 'return its code' do
      SerializableProc.new{ x }.to_s.should == 'lambda { x }'
    end
  end

end
