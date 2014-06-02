require File.join(File.dirname(__FILE__), '..', 'spec_helper')

[:[], :call].each do |invoke|
  describe "Invoking with class vars using :#{invoke}" do

    describe '>> (w isolation)' do

      should 'not be affected by out-of-scope changes when wo specified binding' do
        @@x, @@y = 'awe', 'some'
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal('handsome')
      end

      should 'not effect out-of-scope changes when wo specified binding' do
        @@x, @@y = 'awe', 'some'
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke)
        @@x.should.equal('wonder')
      end

      should 'not be affected by out-of-scope changes even when w specified binding' do
        @@x, @@y = 'awe', 'some'
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

      should 'not effect out-of-scope changes even when w specified binding' do
        @@x, @@y = 'awe', 'some'
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke, binding)
        @@x.should.equal('wonder')
      end

    end

    describe '>> (wo isolation)' do

      # if RUBY_VERSION.include?('1.9.')

      #   should 'raise NameError when wo specified binding' do
      #     @@x, @@y = 'wonder', 'ful'
      #     s_proc = SerializableProc.new do
      #       @@_not_isolated_vars = :class
      #       @@x.sub!('awe','hand')
      #       @@x + @@y
      #     end
      #     @@x, @@y = 'awe', 'some'
      #     lambda { s_proc.send(invoke) }.should.raise(NameError)
      #   end

      # else
      # At least Ruby 1.9.3-p448 behaves the way it is below 
        should 'reflect out-of-scope vars even when wo specified binding' do
          @@x, @@y = 'wonder', 'ful'
          s_proc = SerializableProc.new do
            @@_not_isolated_vars = :class
            @@x.sub!('awe','hand')
            @@x + @@y
          end
          @@x, @@y = 'awe', 'some'
          s_proc.send(invoke).should.equal('handsome')
        end

      # end

      should 'be affected by out-of-scope changes w specified binding' do
        @@x, @@y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :class
          @@x.sub!('awe','hand')
          @@x + @@y
        end
        @@x, @@y = 'awe', 'some'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

      should 'effect out-of-scope changes w specified binding' do
        @@x, @@y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :class
          @@x.sub!('awe','hand')
          @@x + @@y
        end
        @@x, @@y = 'awe', 'some'
        s_proc.send(invoke, binding)
        @@x.should.equal('hand')
      end

    end

  end
end
