require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extra functionalities' do

  describe '>> to_sexp (empty proc)' do

    before do
      @s_proc = SerializableProc.new{}
      @expected = {
        :extracted => s(:iter, s(:call, nil, :proc, s(:arglist)), nil),
        :runnable => s(:iter, s(:call, nil, :proc, s(:arglist)), nil)
      }
    end

    should 'return sexp representation of extracted code w debug unspecified' do
      @s_proc.to_sexp.should.equal(@expected[:extracted])
    end

    should 'return sexp representation of extracted code w debug as false' do
      @s_proc.to_sexp(false).should.equal(@expected[:extracted])
    end

    should 'return sexp representation of extracted code w debug as true' do
      @s_proc.to_sexp(true).should.equal(@expected[:runnable])
    end

  end

  describe '>> to_sexp (single statement proc)' do

    before do
      @s_proc = SerializableProc.new{ @x }
      @expected = {
        :extracted => s(:iter, s(:call, nil, :proc, s(:arglist)), nil, s(:ivar, :@x)),
        :runnable => s(:iter, s(:call, nil, :proc, s(:arglist)), nil, s(:lvar, :ivar_x))
      }
    end

    should 'return sexp representation of extracted code w debug unspecified' do
      @s_proc.to_sexp.should.equal(@expected[:extracted])
    end

    should 'return sexp representation of extracted code w debug as false' do
      @s_proc.to_sexp(false).should.equal(@expected[:extracted])
    end

    should 'return sexp representation of extracted code w debug as true' do
      @s_proc.to_sexp(true).should.equal(@expected[:runnable])
    end

  end

  describe '>> to_sexp (multi statements proc)' do

    before do
      @s_proc = SerializableProc.new do
        @a = 1
        @b = 2
      end
      @expected = {
        :extracted => s(:iter, s(:call, nil, :proc, s(:arglist)), nil, s(:block,
          s(:iasgn, :@a, s(:lit, 1)), s(:iasgn, :@b, s(:lit, 2)))),
        :runnable => s(:iter, s(:call, nil, :proc, s(:arglist)), nil, s(:block,
          s(:lasgn, :ivar_a, s(:lit, 1)), s(:lasgn, :ivar_b, s(:lit, 2))))
      }
    end

    should 'return sexp representation of extracted code w debug unspecified' do
      @s_proc.to_sexp.should.equal(@expected[:extracted])
    end

    should 'return sexp representation of extracted code w debug as false' do
      @s_proc.to_sexp(false).should.equal(@expected[:extracted])
    end

    should 'return sexp representation of extracted code w debug as true' do
      @s_proc.to_sexp(true).should.equal(@expected[:runnable])
    end

  end

end
