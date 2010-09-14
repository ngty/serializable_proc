require File.join(File.dirname(__FILE__), '..', 'spec_helper')

[:[], :call].each do |invoke|
  describe "Invoking with args using :#{invoke}" do

    describe '>> wo specified binding' do

      should 'return yield result given no arg' do
        s_proc = SerializableProc.new { %w{b c}.map{|x| x } }
        s_proc.send(invoke).should.equal(%w{b c})
      end

      should 'return yield result given single arg' do
        s_proc = SerializableProc.new do |i|
          %w{b c}.map{|x| x*i }
        end
        s_proc.send(invoke, 2).should.equal(%w{bb cc})
      end

      should 'return yield result given optional args' do
        s_proc = SerializableProc.new {|*args| %w{b c}.map{|x| [x,args].flatten.join } }
        s_proc.send(invoke, '1', '2').should.equal(%w{b12 c12})
      end

      should 'return yield result given multiple args' do
        s_proc = SerializableProc.new {|i, j| %w{b c}.map{|x| x*i*j } }
        s_proc.send(invoke, 2, 3).should.equal(%w{bbbbbb cccccc})
      end

    end

    describe '>> w specified binding' do

      should 'return yield result given no arg' do
        x = 'a'
        s_proc = SerializableProc.new { %w{b c}.map{|x| x } }
        s_proc.send(invoke, binding).should.equal(%w{b c})
      end

      should 'return yield result given single arg' do
        x = 'a'
        s_proc = SerializableProc.new do |i|
          %w{b c}.map{|x| x*i }
        end
        s_proc.send(invoke, 2, binding).should.equal(%w{bb cc})
      end

      should 'return yield result given optional args' do
        x = 'a'
        s_proc = SerializableProc.new {|*args| %w{b c}.map{|x| [x,args].flatten.join } }
        s_proc.send(invoke, '1', '2', binding).should.equal(%w{b12 c12})
      end

      should 'return yield result given multiple args' do
        x = 'a'
        s_proc = SerializableProc.new {|i, j| %w{b c}.map{|x| x*i*j } }
        s_proc.send(invoke, 2, 3, binding).should.equal(%w{bbbbbb cccccc})
      end

    end
  end
end
