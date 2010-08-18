require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Subclassing w zero arity' do

  extend SerializableProc::Spec::Helpers
  expected_file = File.expand_path(__FILE__)
  expected_code = "lambda { [\"a\", \"b\"].map { |lvar_x| puts(lvar_x) } }"

  should "handle block using do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new do
        %w{a b}.map{|x| puts x }
      end
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using do ... end [##{__LINE__}]" do
    (Otaky::MagicProc.new do %w{a b}.map{|x| puts x } end).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (
      Otaky::MagicProc.new {
        %w{a b}.map{|x| puts x }
      }
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new { %w{a b}.map{|x| puts x } }).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with lambda { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new(&(lambda { %w{a b}.map{|x| puts x } }))).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with lambda do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new(&(lambda do
        %w{a b}.map{|x| puts x }
      end))
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle fanciful initializing with proc { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new(&(proc { %w{a b}.map{|x| puts x } }))).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with proc do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new(&(proc do
        %w{a b}.map{|x| puts x }
      end))
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle fanciful initializing with Proc.new { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new(&(Proc.new { %w{a b}.map{|x| puts x } }))).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with Proc.new do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new(&(Proc.new do
        %w{a b}.map{|x| puts x }
      end))
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

end
