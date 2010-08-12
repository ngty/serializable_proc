require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'Zero arity serializable proc' do

  extend SerializableProc::Spec::Helpers

  expected_file = File.expand_path(__FILE__)
  expected_code = "lambda { [\"a\", \"b\"].map { |lvar_x| puts(lvar_x) } }"

  should_handle_proc_variable expected_file, expected_code, {
    # ////////////////////////////////////////////////////////////////////////
    # >> Always newlinling
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ =>
        lambda do
          %w{a b}.map do |x|
            puts x
          end
        end,
      __LINE__ =>
        lambda {
          %w{a b}.map{|x|
            puts x
          }
        },
      __LINE__ =>
        proc do
          %w{a b}.map do |x|
            puts x
          end
        end,
      __LINE__ =>
        lambda {
          %w{a b}.map{|x|
            puts x
          }
        },
      __LINE__ =>
        Proc.new do
          %w{a b}.map do |x|
            puts x
          end
        end,
      __LINE__ =>
        Proc.new {
          %w{a b}.map{|x|
            puts x
          }
        },
    # ////////////////////////////////////////////////////////////////////////
    # >> Partial newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ =>
        lambda do
          %w{a b}.map do |x| puts x end
        end,
      __LINE__ =>
        lambda {
          %w{a b}.map{|x| puts x }
        },
      __LINE__ =>
        proc do
          %w{a b}.map do |x| puts x end
        end,
      __LINE__ =>
        lambda {
          %w{a b}.map{|x| puts x }
        },
      __LINE__ =>
        Proc.new do
          %w{a b}.map do |x| puts x end
        end,
      __LINE__ =>
        Proc.new {
          %w{a b}.map{|x| puts x }
        },
    # ////////////////////////////////////////////////////////////////////////
    # >> No newlining
    # ////////////////////////////////////////////////////////////////////////
      __LINE__ =>
        lambda do %w{a b}.map do |x| puts x end end,
      __LINE__ =>
        lambda { %w{a b}.map{|x| puts x } },
      __LINE__ =>
        proc do %w{a b}.map do |x| puts x end end,
      __LINE__ =>
        lambda { %w{a b}.map{|x| puts x } },
      __LINE__ =>
        Proc.new do %w{a b}.map do |x| puts x end end,
      __LINE__ =>
        Proc.new { %w{a b}.map{|x| puts x } },
    }

  should "handle block using do ... end [##{__LINE__}]" do
    (
      SerializableProc.new do
        %w{a b}.map{|x| puts x }
      end
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using do ... end [##{__LINE__}]" do
    (SerializableProc.new do %w{a b}.map{|x| puts x } end).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (
      SerializableProc.new {
        %w{a b}.map{|x| puts x }
      }
    ).should.be having_expected_proc_attrs(expected_file, __LINE__ - 3, expected_code)
  end

  should "handle block using { ... } [##{__LINE__}]" do
    (SerializableProc.new { %w{a b}.map{|x| puts x } }).
      should.be having_expected_proc_attrs(expected_file, __LINE__.pred, expected_code)
  end

end
