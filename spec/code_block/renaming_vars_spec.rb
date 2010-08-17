require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Renaming variables' do

  describe '>> wo specified @@_not_isolated_vars' do
    extend SerializableProc::Spec::Helpers

    should 'handle global, class, instance & local' do
      x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
      SerializableProc.new{ [x, @x, @@x, $x] }.should.be \
        having_runnable_code_as('lambda{ [lvar_x, ivar_x, cvar_x, gvar_x] }')
    end

    should 'not handle block-scoped ones (single)' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          [x, @x, @@x, $x]
          def test(x) ; [x, @x, @@x, $x] ; end
        end
      ).should.be having_runnable_code_as('
        lambda do
          [lvar_x, ivar_x, cvar_x, gvar_x]
          def test(x) ; [x, @x, @@x, $x] ; end
        end
      ')
    end

    should 'not handle block-scoped ones (multiple)' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          [x, @x, @@x, $x]
          def test1(x) ; [x, @x, @@x, $x] ; end
          def test2(x) ; [x, @x, @@x, $x] ; end
        end
      ).should.be having_runnable_code_as('
        lambda do
          [lvar_x, ivar_x, cvar_x, gvar_x]
          def test1(x) ; [x, @x, @@x, $x] ; end
          def test2(x) ; [x, @x, @@x, $x] ; end
        end
      ')
    end

  end

  describe '>> w @@_not_isolated_vars specified' do
    extend SerializableProc::Spec::Helpers

    should 'handle only class, instance & local w only :global' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          @@_not_isolated_vars = :global
          [x, @x, @@x, $x]
        end
      ).should.be having_runnable_code_as('
        lambda do
          @@_not_isolated_vars = :global
          [lvar_x, ivar_x, cvar_x, $x]
        end
      ')
    end

    should 'handle only global, instance & local w only :class' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          @@_not_isolated_vars = :class
          [x, @x, @@x, $x]
        end
      ).should.be having_runnable_code_as('
        lambda do
          @@_not_isolated_vars = :class
          [lvar_x, ivar_x, @@x, gvar_x]
        end
      ')
    end

    should 'handle only global, class & local w only :instance' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          @@_not_isolated_vars = :instance
          [x, @x, @@x, $x]
        end
      ).should.be having_runnable_code_as('
        lambda do
          @@_not_isolated_vars = :instance
          [lvar_x, @x, cvar_x, gvar_x]
        end
      ')
    end

    should 'handle only global, class & instance w only :local' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          @@_not_isolated_vars = :local
          [x, @x, @@x, $x]
        end
      ).should.be having_runnable_code_as('
        lambda do
          @@_not_isolated_vars = :local
          [x, ivar_x, cvar_x, gvar_x]
        end
      ')
    end

    should 'handle only instance & local w :global & :class' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          @@_not_isolated_vars = :global, :class
          [x, @x, @@x, $x]
        end
      ).should.be having_runnable_code_as('
        lambda do
          @@_not_isolated_vars = :global, :class
          [lvar_x, ivar_x, @@x, $x]
        end
      ')
    end

    should 'not handle block-scoped ones (single)' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          @@_not_isolated_vars = :global, :class
          def test(x) ; [x, @x, @@x, $x] ; end
        end
      ).should.be having_runnable_code_as('
        lambda do
          @@_not_isolated_vars = :global, :class
          def test(x) ; [x, @x, @@x, $x] ; end
        end
      ')
    end

    should 'not handle block-scoped ones (multiple)' do
      (
        x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
        SerializableProc.new do
          @@_not_isolated_vars = :global, :class
          def test1(x) ; [x, @x, @@x, $x] ; end
          def test2(x) ; [x, @x, @@x, $x] ; end
        end
      ).should.be having_runnable_code_as('
        lambda do
          @@_not_isolated_vars = :global, :class
          def test1(x) ; [x, @x, @@x, $x] ; end
          def test2(x) ; [x, @x, @@x, $x] ; end
        end
      ')
    end

  end

end
