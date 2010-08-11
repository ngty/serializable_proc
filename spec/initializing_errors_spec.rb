require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Initializing errors' do

  unless $parse_tree_installed
    describe '>> SerializableProc::CannotInitializeError' do

      extend SerializableProc::Spec::Helpers

      should "raise if line has more than 1 'SerializableProc.new'" do
        lambda {
          SerializableProc.new {} ; SerializableProc.new { |arg| %w{a b}.map{|x| puts x } }
        }.should.be raising_cannot_initialize_error('SerializableProc.new')
      end

      should "raise if line has more than 1 'Proc.new'" do
        lambda {
          p1 = Proc.new {} ; p2 = Proc.new { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_initialize_error('Proc.new')
      end

      should "raise if line has more than 1 'lambda'" do
        lambda {
          p1 = lambda {} ; p2 = lambda { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_initialize_error('lambda')
      end

      should "raise if line has more than 1 'proc'" do
        lambda {
          p1 = proc {} ; p2 = proc { |arg| %w{a b}.map{|x| puts x } }
          SerializableProc.new(&p2)
        }.should.be raising_cannot_initialize_error('proc')
      end

    end
  end

  describe '>> SerializableProc::CannotSerializeVariableError' do

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

end
