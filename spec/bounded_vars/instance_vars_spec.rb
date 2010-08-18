require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe 'Extracting instance vars' do

  extend SerializableProc::Spec::Helpers

  should 'handle outer-scoped ones if @@_not_isolated_vars excludes :instance' do
    @x, @y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_not_isolated_vars = nil
        @x + @y
      }, {:ivar_x => @x, :ivar_y => @y}
  end

  should "handle inner-scoped ones if @@_not_isolated_vars excludes :instance" do
    @x, @y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @@_not_isolated_vars = nil
        @z = 'wonder'
        %w{a b}.each{ puts @z, @x, @y }
      }, {:ivar_x => @x, :ivar_y => @y, :ivar_z => nil}
  end

  should 'not handle outer-scoped ones if @@_not_isolated_vars includes :instance' do
    @x, @y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :instance
        @x + @y
      }
  end

  should 'not handle outer-scoped ones if @@_not_isolated_vars includes :all' do
    @x, @y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :all
        @x + @y
      }
  end

  should "not handle inner-scoped ones if @@_not_isolated_vars includes :instance" do
    @x, @y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :instance
        @z = 'wonder'
        %w{a b}.each{ puts @z, @x, @y }
      }
  end

  should "not handle inner-scoped ones if @@_not_isolated_vars includes :all" do
    @x, @y = 'awe', 'some'
    should_have_empty_binding \
      SerializableProc.new {
        @@_not_isolated_vars = :all
        @z = 'wonder'
        %w{a b}.each{ puts @z, @x, @y }
      }
  end

  should 'handle outer-scoped ones w @@_not_isolated_vars unspecified' do
    @x, @y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new { @x + @y }, {:ivar_x => @x, :ivar_y => @y}
  end

  should "handle inner-scoped ones w @@_not_isolated_vars unspecified" do
    @x, @y = 'awe', 'some'
    should_have_expected_binding \
      SerializableProc.new {
        @z = 'wonder'
        %w{a b}.each{ puts @z, @x, @y }
      }, {:ivar_x => @x, :ivar_y => @y, :ivar_z => nil}
  end

end
