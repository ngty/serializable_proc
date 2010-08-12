require 'rubygems'
require 'forwardable'
require 'ruby2ruby'
require 'serializable_proc/marshalable'
require 'serializable_proc/parsers'
require 'serializable_proc/binding'
require 'serializable_proc/sandboxer'

begin
  require 'parse_tree'
  require 'parse_tree_extensions'
rescue LoadError
  require 'ruby_parser'
end

class SerializableProc

  class GemNotInstalledError         < Exception ; end
  class CannotInitializeError        < Exception ; end
  class CannotSerializeVariableError < Exception ; end

  include Marshalable
  marshal_attrs :file, :line, :code, :binding

  def initialize(&block)
    file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
    @file, @line = File.expand_path(file), line.to_i
    @code, sexp = Parsers::PT.process(block) || Parsers::RP.process(self.class, @file, @line)
    @binding = Binding.new(block.binding, sexp)
  end

  def ==(other)
    other.object_id == object_id or
      other.is_a?(self.class) && other.to_s == to_s
  end

  def to_proc
    @proc ||= eval(@code, binding, @file, @line)
  end

  def to_s
    @code
  end

  def call(*args)
    to_proc.call(*args)
  end

  alias_method :[], :call

  def binding
    @binding.eval!
  end

end
