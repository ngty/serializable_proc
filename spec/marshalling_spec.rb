require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Marshalling' do

  before do
    @proc = SerializableProc.new{ %w{a b}.map{|x| x } }
  end

  should 'be able to marshal' do
    Marshal.load(Marshal.dump(@proc))
    true.should.be.true # the above should execute wo error
  end

  should 'be able to resume proc behaviours after marshal' do
    Marshal.load(Marshal.dump(@proc)).call.should.equal(%w{a b})
  end

end

