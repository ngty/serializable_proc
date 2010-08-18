require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Subclassing w single arity' do

  expected_file = File.expand_path(__FILE__)
  expected_code = "lambda { |lvar_arg| [\"a\", \"b\"].map { |lvar_x| puts(lvar_x) } }"

  describe '>> wo args' do

    extend SerializableProc::Spec::Helpers
    behaves_like 'has support for parsing Otaky.work (wo args)'

    should "handle block using do ... end [##{__LINE__}]" do
      (
        Otaky.work do |arg|
          %w{a b}.map{|x| puts x }
        end
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using do ... end [##{__LINE__}]" do
      (Otaky.work do |arg| %w{a b}.map{|x| puts x } end).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (
        Otaky.work { |arg|
          %w{a b}.map{|x| puts x }
        }
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle block using { ... } [##{__LINE__}]" do
      (Otaky.work { |arg| %w{a b}.map{|x| puts x } }).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda { ... } [##{__LINE__}]" do
      (Otaky.work(&(lambda { |arg| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with lambda do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(lambda do |arg|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with proc { ... } [##{__LINE__}]" do
      (Otaky.work(&(proc { |arg| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with proc do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(proc do |arg|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

    should "handle fanciful initializing with Proc.new { ... } [##{__LINE__}]" do
      (Otaky.work(&(Proc.new { |arg| %w{a b}.map{|x| puts x } }))).
        should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
    end

    should "handle fanciful initializing with Proc.new do ... end [##{__LINE__}]" do
      (
        Otaky.work(&(Proc.new do |arg|
          %w{a b}.map{|x| puts x }
        end))
      ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
    end

  end

end
