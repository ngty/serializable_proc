require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Assigning context' do

  class << self
    def m1    ; 'm1' ; end
    def m2(x) ; 'm2(%s)' % x ; end
  end

  should "extract local variables & and assign them as context [##{__LINE__}]" do
    x, y = 'awe', 'some'
    s_proc = SerializableProc.new { x + y }
    s_proc.context.hash.should.equal(:x => 'awe', :y => 'some')
  end

  should "not call methods & and assign them as context [##{__LINE__}]" do
    x, y = 'awe', 'some'
    s_proc = SerializableProc.new { x + y + m1 + m2(3) }
    s_proc.context.hash.should.equal(:x => 'awe', :y => 'some')
  end

end
