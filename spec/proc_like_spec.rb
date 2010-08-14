require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Being proc like' do

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

    should 'reflect bound instance variable value (unaffected by outside-scope change)' do
      x, y = 'awe', 'some'
      expected = 'hand' + y
      s_proc = SerializableProc.new { x.sub!('awe','hand'); x + y }
      x, y = 'wonder', 'ful'
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'not affect any outside-scope change to instance variable' do
      x, y = 'awe', 'some'
      s_proc = SerializableProc.new { x.sub!('awe','hand'); x + y }
      x, y = 'wonder', 'ful'
      s_proc.call ; s_proc[]
      x.should.equal('wonder')
      y.should.equal('ful')
    end

    should 'reflect bound instance variable value (unaffected by outside-scope change)' do
      @x, @y = 'awe', 'some'
      expected = 'hand' + @y
      s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
      @x, @y = 'wonder', 'ful'
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'not affect any outside-scope change to instance variable' do
      @x, @y = 'awe', 'some'
      s_proc = SerializableProc.new { @x.sub!('awe','hand'); @x + @y }
      @x, @y = 'wonder', 'ful'
      s_proc.call ; s_proc[]
      @x.should.equal('wonder')
      @y.should.equal('ful')
    end

    should 'reflect bound class variable value (unaffected by outside-scope change)' do
      @@x, @@y = 'awe', 'some'
      expected = 'hand' + @@y
      s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
      @@x, @@y = 'wonder', 'ful'
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'not affect any outside-scope change to class variable' do
      @@x, @@y = 'awe', 'some'
      s_proc = SerializableProc.new { @@x.sub!('awe','hand'); @@x + @@y }
      @@x, @@y = 'wonder', 'ful'
      s_proc.call ; s_proc[]
      @@x.should.equal('wonder')
      @@y.should.equal('ful')
    end

    should 'reflect bound global variable value (unaffected by outside-scope change)' do
      $x, $y = 'awe', 'some'
      expected = 'hand' + $y
      s_proc = SerializableProc.new { $x.sub!('awe','hand'); $x + $y }
      $x, $y = 'wonder', 'ful'
      s_proc.call.should.equal(expected)
      s_proc[].should.equal(expected)
    end

    should 'not affect any outside-scope change to global variable' do
      $x, $y = 'awe', 'some'
      s_proc = SerializableProc.new { $x.sub!('awe','hand'); $x + $y }
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
    should 'raise NotImplementedError' do
      lambda { SerializableProc.new { x }.binding }.should.raise(NotImplementedError)
    end
    # should 'return binding that contains duplicated contextual reference values' do
    #   x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
    #   expected = {'x' => x.dup, '@x' => @x.dup, '@@x' => @@x.dup, '$x' => $x.dup}
    #   s_proc = SerializableProc.new { [x, @x, @@x, $x] }
    #   x, @x, @@x, $x = 'ly', 'iy', 'cy', 'gy'
    #   expected.each{|k,v| s_proc.binding.eval(k).should.equal(v) }
    # end
  end

  describe '>> to_proc' do

    class << self
      def work(&block) ; yield ; end
    end

    should 'return a non-serializable proc' do
      o_proc = lambda { %w{b c}.map{|x| x } }
      s_proc = SerializableProc.new(&o_proc)
      n_proc = s_proc.to_proc
      s_proc.should.not == n_proc
      n_proc.class.should == Proc
      n_proc.call.should.equal(o_proc.call)
    end

    should "support passing to a method using '&' char" do
      s_proc = SerializableProc.new { %w{b c}.map{|x| x } }
      work(&s_proc).should.equal(%w{b c})
    end

  end

  describe '>> to_s' do

    extend SerializableProc::Spec::Helpers

    should 'return extracted code when debug is not specified' do
      x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
      SerializableProc.new{ [x,@x,@@x,$x] }.to_s.should.be \
        having_same_semantics_as('lambda { [x, @x, @@x, $x] }')
    end

    should 'return extracted code when debug is turned off' do
      x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
      SerializableProc.new{ [x,@x,@@x,$x] }.to_s(false).should.be \
        having_same_semantics_as('lambda { [x, @x, @@x, $x] }')
    end

    should 'return runnable code when debug is turned on' do
      x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
      SerializableProc.new{ [x,@x,@@x,$x] }.to_s(true).should.be \
        having_same_semantics_as('lambda { [lvar_x, ivar_x, cvar_x, gvar_x] }')
    end

  end

  describe '>> arity' do
    {
      __LINE__ => lambda { },
      __LINE__ => lambda {|x| },
      __LINE__ => lambda {|x,y| },
      __LINE__ => lambda {|*x| },
      __LINE__ => lambda {|x, *y| },
      __LINE__ => lambda {|(x,y)| },
    }.each do |debug, block|
      should "return arity of initializing block [##{debug}]" do
        SerializableProc.new(&block).arity.should.equal(block.arity)
      end
    end
  end

end
