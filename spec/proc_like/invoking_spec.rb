require File.join(File.dirname(__FILE__), '..', 'spec_helper')

[:[], :call].each do |invoke|
  describe "Invoking SerializableProc w :#{invoke}" do

    should 'return yield result given no arg' do
      s_proc = SerializableProc.new { %w{b c}.map{|x| x } }
      expected = %w{b c}
      s_proc.send(invoke).should.equal(expected)
    end

    describe '>> w isolation' do

      should 'reflect bound instance vars value (unaffected by outside-scope change)' do
        x, y = 'awe', 'some'
        expected = 'hand' + y
        s_proc = SerializableProc.new { x.sub!('awe','hand'); x + y }
        x, y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to instance vars' do
        x, y = 'awe', 'some'
        s_proc = SerializableProc.new { x.sub!('awe','hand'); x + y }
        x, y = 'wonder', 'ful'
        s_proc.send(invoke)
        x.should.equal('wonder')
        y.should.equal('ful')
      end

      should 'reflect bound instance vars value (unaffected by outside-scope change)' do
        @x, @y = 'awe', 'some'
        expected = 'hand' + @y
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to instance vars' do
        @x, @y = 'awe', 'some'
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke)
        @x.should.equal('wonder')
        @y.should.equal('ful')
      end

      should 'reflect bound class vars value (unaffected by outside-scope change)' do
        @@x, @@y = 'awe', 'some'
        expected = 'hand' + @@y
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to class vars' do
        @@x, @@y = 'awe', 'some'
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke)
        @@x.should.equal('wonder')
        @@y.should.equal('ful')
      end

      should 'reflect bound global vars value (unaffected by outside-scope change)' do
        $x, $y = 'awe', 'some'
        expected = 'hand' + $y
        s_proc = SerializableProc.new { $x.sub!('awe','hand'); $x + $y }
        $x, $y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to global vars' do
        $x, $y = 'awe', 'some'
        s_proc = SerializableProc.new { $x.sub!('awe','hand'); $x + $y }
        $x, $y = 'wonder', 'ful'
        s_proc.send(invoke)
        $x.should.equal('wonder')
        $y.should.equal('ful')
      end

    end

    describe '>> wo isolation' do

      should 'raise NameError for local vars wo specified binding' do
        x, y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :local
          x.sub!('awe','hand')
          x + y
        end
        x, y = 'awe', 'some'
        lambda { s_proc.send(invoke) }.should.raise(NameError)
      end

      should 'reflect local vars within specified binding' do
        x, y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :local
          x.sub!('awe','hand')
          x + y
        end
        x, y = 'awe', 'some'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

      should 'raise NameError for instance vars wo specified binding' do
        @x, @y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :instance
          @x.sub!('awe','hand')
          @x + @y
        end
        @x, @y = 'awe', 'some'
        lambda { s_proc.send(invoke) }.should.raise(NameError)
      end

      should 'reflect instance vars within specified binding' do
        @x, @y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :instance
          @x.sub!('awe','hand')
          @x + @y
        end
        @x, @y = 'awe', 'some'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

      if RUBY_VERSION.include?('1.9.')

        should 'raise NameError for class vars wo specified binding' do
          @@x, @@y = 'wonder', 'ful'
          s_proc = SerializableProc.new do
            @@_not_isolated_vars = :class
            @@x.sub!('awe','hand')
            @@x + @@y
          end
          @@x, @@y = 'awe', 'some'
          lambda { s_proc.send(invoke) }.should.raise(NameError)
        end

      else

        should 'reflect outside-scope class vars wo specified binding' do
          @@x, @@y = 'wonder', 'ful'
          s_proc = SerializableProc.new do
            @@_not_isolated_vars = :class
            @@x.sub!('awe','hand')
            @@x + @@y
          end
          @@x, @@y = 'awe', 'some'
          s_proc.send(invoke).should.equal('handsome')
        end

      end

      should 'reflect class vars within specified binding' do
        @@x, @@y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :class
          @@x.sub!('awe','hand')
          @@x + @@y
        end
        @@x, @@y = 'awe', 'some'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

      should ' reflect outside-scope global vars wo specified binding' do
        $x, $y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :global
          $x.sub!('awe','hand')
          $x + $y
        end
        $x, $y = 'awe', 'some'
        s_proc.send(invoke).should.equal('handsome')
      end

      should 'reflect global vars within specified binding' do
        $x, $y = 'wonder', 'ful'
        s_proc = SerializableProc.new do
          @@_not_isolated_vars = :global
          $x.sub!('awe','hand')
          $x + $y
        end
        $x, $y = 'awe', 'some'
        s_proc.send(invoke, binding).should.equal('handsome')
      end

    end

  end
end
