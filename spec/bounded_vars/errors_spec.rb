require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'SerializableProc::CannotSerializeVariableError' do

  extend SerializableProc::Spec::Helpers

  should "raise if local variable cannot be marshalled" do
    f = Tempfile.new('fake')
    lambda { SerializableProc.new{ f } }.should.be raising_cannot_serialize_variable_error('f')
  end

  should "raise if class variable cannot be marshalled" do
    @@f = Tempfile.new('fake')
    lambda { SerializableProc.new{ @@f } }.should.be raising_cannot_serialize_variable_error('@@f')
  end

  should "raise if instance variable cannot be marshalled" do
    @f = Tempfile.new('fake')
    lambda { SerializableProc.new{ @f } }.should.be raising_cannot_serialize_variable_error('@f')
  end

  should "raise if global variable cannot be marshalled" do
    $f = Tempfile.new('fake')
    lambda { SerializableProc.new{ $f } }.should.be raising_cannot_serialize_variable_error('$f')
  end

end
