require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Subclassing w optional arity' do

  expected_file = File.expand_path(__FILE__)
  expected_code = "lambda { |*lvar_args| [\"a\", \"b\"].map { |lvar_x| puts(lvar_x) } }"

  describe '>> wo args' do

    extend SerializableProc::Spec::Helpers
    behaves_like 'has support for parsing Otaky.work (wo args)'

    should "handle block using do ... end [##{__LINE__}]" do
      (
        Otaky.work do |*args|
          %w{a b}.map{|x| puts x }
        end
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      (Otaky.work do |*args| %w{a b}.map{|x| puts x } end).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (
        Otaky.work { |*args|
          %w{a b}.map{|x| puts x }
        }
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (Otaky.work { |*args| %w{a b}.map{|x| puts x } }).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda { ... } [##{__LINE__}]" do
      (Otaky.work(&(lambda { |*args| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(lambda do |*args|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with proc { ... } [##{__LINE__}]" do
      (Otaky.work(&(proc { |*args| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with proc do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(proc do |*args|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with Proc.new { ... } [##{__LINE__}]" do
      (Otaky.work(&(Proc.new { |*args| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with Proc.new do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(Proc.new do |*args|
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
        Otaky.work(1, :a => 2, :b => 3) do |*args|
          %w{a b}.map{|x| puts x }
        end
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      (Otaky.work(1, :a => 2, :b => 3) do |*args| %w{a b}.map{|x| puts x } end).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (
        Otaky.work(1, :a => 2, :b => 3) { |*args|
          %w{a b}.map{|x| puts x }
        }
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (Otaky.work(1, :a => 2, :b => 3) { |*args| %w{a b}.map{|x| puts x } }).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda { ... } [##{__LINE__}]" do
      (Otaky.work(1, {:a => 2, :b => 3}, &(lambda { |*args| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda do ... end [##{__LINE__}]" do
      (
        Otaky.work(1, {:a => 2, :b => 3}, &(lambda do |*args|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with proc { ... } [##{__LINE__}]" do
      (Otaky.work(1, {:a => 2, :b => 3}, &(proc { |*args| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with proc do ... end [##{__LINE__}]" do
      (
        Otaky.work(1, {:a => 2, :b => 3}, &(proc do |*args|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with Proc.new { ... } [##{__LINE__}]" do
      (Otaky.work(1, {:a => 2, :b => 3}, &(Proc.new { |*args| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with Proc.new do ... end [##{__LINE__}]" do
      (
        Otaky.work(1, {:a => 2, :b => 3}, &(Proc.new do |*args|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

  end

end
