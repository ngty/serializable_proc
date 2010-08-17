require File.join(File.dirname(__FILE__), '..', 'spec_helper')

[:[], :call].each do |invoke|
  describe "Invoking with instance vars using :#{invoke}" do

    describe '>> (w isolation)' do

      should 'not be affected by out-of-scope changes when wo specified binding' do
        @x, @y = 'awe', 'some'
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal('handsome')
      end

      should 'not effect out-of-scope changes when wo specified binding' do
        @x, @y = 'awe', 'some'
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke)
        @x.should.equal('wonder')
      end

      should 'not be affected by out-of-scope changes even when w specified binding' do
        @x, @y = 'awe', 'some'
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

      should 'not effect out-of-scope changes even when w specified binding' do
        @x, @y = 'awe', 'some'
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke, binding)
        @x.should.equal('wonder')
      end

    end

    describe '>> (wo isolation)' do

      should 'raise NameError when wo specified binding' do
        @x, @y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :instance
          @x.sub!('awe','hand')
          @x + @y
        end
        @x, @y = 'awe', 'some'
        lambda { s_proc.send(invoke) }.should.raise(NameError)
      end

      should 'be affected by out-of-scope changes w specified binding' do
        @x, @y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :instance
          @x.sub!('awe','hand')
          @x + @y
        end
        @x, @y = 'awe', 'some'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

      should 'effect out-of-scope changes w specified binding' do
        @x, @y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :instance
          @x.sub!('awe','hand')
          @x + @y
        end
        @x, @y = 'awe', 'some'
        s_proc.send(invoke, binding)
        @x.should.equal('hand')
      end

    end

  end
end
