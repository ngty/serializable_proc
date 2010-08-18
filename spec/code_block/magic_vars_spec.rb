require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Handling magic vars' do

  extend SerializableProc::Spec::Helpers

  should 'convert __FILE__' do
    SerializableProc.new { __FILE__ }.should.be \
      having_runnable_code_as('proc { "%s" }' % __FILE__)
  end

  should 'convert __LINE__' do
    SerializableProc.new { __LINE__ }.should.be \
      having_runnable_code_as('proc { %s }' % __LINE__.pred)
  end

end
