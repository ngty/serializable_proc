require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Subclassing w multiple arities' do

  extend SerializableProc::Spec::Helpers
  expected_file = File.expand_path(__FILE__)
  expected_code = "lambda { |lvar_arg1, lvar_arg2| [\"a\", \"b\"].map { |lvar_x| puts(lvar_x) } }"

  should "handle block using do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new do |arg1, arg2|
        %w{a b}.map{|x| puts x }
      end
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using do ... end [##{__LINE__}]" do
    (Otaky::MagicProc.new do |arg1, arg2| %w{a b}.map{|x| puts x } end).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (
      Otaky::MagicProc.new { |arg1, arg2|
        %w{a b}.map{|x| puts x }
      }
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new { |arg1, arg2| %w{a b}.map{|x| puts x } }).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with lambda { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new(&(lambda { |arg1, arg2| %w{a b}.map{|x| puts x } }))).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with lambda do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new(&(lambda do |arg1, arg2|
        %w{a b}.map{|x| puts x }
      end))
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle fanciful initializing with proc { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new(&(proc { |arg1, arg2| %w{a b}.map{|x| puts x } }))).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with proc do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new(&(proc do |arg1, arg2|
        %w{a b}.map{|x| puts x }
      end))
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle fanciful initializing with Proc.new { ... } [##{__LINE__}]" do
    (Otaky::MagicProc.new(&(Proc.new { |arg1, arg2| %w{a b}.map{|x| puts x } }))).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle fanciful initializing with Proc.new do ... end [##{__LINE__}]" do
    (
      Otaky::MagicProc.new(&(Proc.new do |arg1, arg2|
        %w{a b}.map{|x| puts x }
      end))
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

end
