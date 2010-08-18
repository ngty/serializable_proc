require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Subclassing w zero arity' do

  expected_file = File.expand_path(__FILE__)
  expected_code = "lambda { [\"a\", \"b\"].map { |lvar_x| puts(lvar_x) } }"

  describe '>> wo args' do

    extend SerializableProc::Spec::Helpers
    behaves_like 'has support for parsing Otaky.work (wo args)'

    should "handle block using do ... end [##{__LINE__}]" do
      (
        Otaky.work do
          %w{a b}.map{|x| puts x }
        end
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      (Otaky.work do %w{a b}.map{|x| puts x } end).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (
        Otaky.work {
          %w{a b}.map{|x| puts x }
        }
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (Otaky.work { %w{a b}.map{|x| puts x } }).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda { ... } [##{__LINE__}]" do
      (Otaky.work(&(lambda { %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(lambda do
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with proc { ... } [##{__LINE__}]" do
      (Otaky.work(&(proc { %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with proc do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(proc do
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with Proc.new { ... } [##{__LINE__}]" do
      (Otaky.work(&(Proc.new { %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with Proc.new do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(Proc.new do
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

  end

  describe '>> w args' do

    extend SerializableProc::Spec::Helpers
    behaves_like 'has support for parsing Otaky.work (w args)'

    should "handle block using do ... end [##{__LINE__}]" do
      (
        Otaky.work(1, :a => 2, :b => 3) do
          %w{a b}.map{|x| puts x }
        end
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      (Otaky.work(1, :a => 2, :b => 3) do %w{a b}.map{|x| puts x } end).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (
        Otaky.work(1, :a => 2, :b => 3) {
          %w{a b}.map{|x| puts x }
        }
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (Otaky.work(1, :a => 2, :b => 3) { %w{a b}.map{|x| puts x } }).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda { ... } [##{__LINE__}]" do
      (Otaky.work(1, {:a => 2, :b => 3}, &(lambda { %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda do ... end [##{__LINE__}]" do
      (
        Otaky.work(1, {:a => 2, :b => 3}, &(lambda do
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with proc { ... } [##{__LINE__}]" do
      (Otaky.work(1, {:a => 2, :b => 3}, &(proc { %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with proc do ... end [##{__LINE__}]" do
      (
        Otaky.work(1, {:a => 2, :b => 3}, &(proc do
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with Proc.new { ... } [##{__LINE__}]" do
      (Otaky.work(1, {:a => 2, :b => 3}, &(Proc.new { %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with Proc.new do ... end [##{__LINE__}]" do
      (
        Otaky.work(1, {:a => 2, :b => 3}, &(Proc.new do
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

  end

end
