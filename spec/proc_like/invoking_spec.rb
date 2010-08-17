require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Invoking SerializableProc' do
  [:[], :call].each do |invoke|
    describe ">> #{invoke}" do

      should 'return yield result given no arg' do
        s_proc = SerializableProc.new { %w{b c}.map{|x| x } }
        expected = %w{b c}
        s_proc.send(invoke).should.equal(expected)
      end

      should 'reflect bound instance variable value (unaffected by outside-scope change)' do
        x, y = 'awe', 'some'
        expected = 'hand' + y
        s_proc = SerializableProc.new { x.sub!('awe','hand'); x + y }
        x, y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to instance variable' do
        x, y = 'awe', 'some'
        s_proc = SerializableProc.new { x.sub!('awe','hand'); x + y }
        x, y = 'wonder', 'ful'
        s_proc.send(invoke)
        x.should.equal('wonder')
        y.should.equal('ful')
      end

      should 'reflect bound instance variable value (unaffected by outside-scope change)' do
        @x, @y = 'awe', 'some'
        expected = 'hand' + @y
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to instance variable' do
        @x, @y = 'awe', 'some'
        s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
        @x, @y = 'wonder', 'ful'
        s_proc.send(invoke)
        @x.should.equal('wonder')
        @y.should.equal('ful')
      end

      should 'reflect bound class variable value (unaffected by outside-scope change)' do
        @@x, @@y = 'awe', 'some'
        expected = 'hand' + @@y
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to class variable' do
        @@x, @@y = 'awe', 'some'
        s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
        @@x, @@y = 'wonder', 'ful'
        s_proc.send(invoke)
        @@x.should.equal('wonder')
        @@y.should.equal('ful')
      end

      should 'reflect bound global variable value (unaffected by outside-scope change)' do
        $x, $y = 'awe', 'some'
        expected = 'hand' + $y
        s_proc = SerializableProc.new { $x.sub!('awe','hand'); $x + $y }
        $x, $y = 'wonder', 'ful'
        s_proc.send(invoke).should.equal(expected)
      end

      should 'not affect any outside-scope change to global variable' do
        $x, $y = 'awe', 'some'
        s_proc = SerializableProc.new { $x.sub!('awe','hand'); $x + $y }
        $x, $y = 'wonder', 'ful'
        s_proc.send(invoke)
        $x.should.equal('wonder')
        $y.should.equal('ful')
      end

    end
  end
end
