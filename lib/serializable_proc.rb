require 'rubygems'
require 'forwardable'
require 'ruby2ruby'
require 'serializable_proc/marshalable'
require 'serializable_proc/parsers'
require 'serializable_proc/binding'
require 'serializable_proc/sandboxer'
require 'serializable_proc/fixes'

begin
  require 'parse_tree'
  require 'parse_tree_extensions'
rescue LoadError
  require 'ruby_parser'
end

##
# SerializableProc differs from the vanilla Proc in 2 ways:
#
# #1. Isolated variables
#
# Upon initializing, all variables (local, instance, class & global) within its context
# are extracted from the proc's binding, and are isolated from changes outside the
# proc's scope, thus, achieving a snapshot effect.
#
#   require 'rubygems'
#   require 'serializable_proc'
#
#   x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
#
#   s_proc = SerializableProc.new { [x, @x, @@x, $x].join(', ') }
#   v_proc = Proc.new { [x, @x, @@x, $x].join(', ') }
#
#   x, @x, @@x, $x = 'ly', 'iy', 'cy', 'gy'
#
#   s_proc.call # >> "lx, ix, cx, gx"
#   v_proc.call # >> "ly, iy, cy, gy"
#
# #2. Marshallable
#
# No throwing of TypeError when marshalling a SerializableProc:
#
#   Marshal.load(Marshal.dump(s_proc)).call # >> "lx, ix, cx, gx"
#   Marshal.load(Marshal.dump(v_proc)).call # >> TypeError (cannot dump Proc)
#
class SerializableProc

  include Marshalable
  marshal_attrs :file, :line, :code, :arity, :binding

  ##
  # Creates a new instance of SerializableProc by passing in a code block, in the process,
  # all referenced variables (local, instance, class & global) within the block are
  # extracted and isolated from the current context.
  #
  #   SerializableProc.new {|...| block }
  #   x = lambda { ... }; SerializableProc.new(&x)
  #   y = proc { ... }; SerializableProc.new(&y)
  #   z = Proc.new { ... }; SerializableProc.new(&z)
  #
  # The following will only work if u have ParseTree (not available for 1.9.* & JRuby)
  # installed:
  #
  #   def action(&block) ; SerializableProc.new(&block) ; end
  #   action { ... }
  #
  def initialize(&block)
    file, line = /^#<Proc:0x[0-9A-Fa-f]+@(.+):(\d+).*?>$/.match(block.inspect)[1..2]
    @file, @line, @arity = File.expand_path(file), line.to_i, block.arity
    @code, sexp = Parsers::PT.process(block) || Parsers::RP.process(self.class, @file, @line)
    @binding = Binding.new(block.binding, sexp)
  end

  ##
  # Returns true if +other+ is exactly the same instance, or if +other+ has the same string
  # content.
  #
  #   x = SerializableProc.new { puts 'awesome' }
  #   y = SerializableProc.new { puts 'wonderful' }
  #   z = SerializableProc.new { puts 'awesome' }
  #
  #   x == x # >> true
  #   x == y # >> false
  #   x == z # >> true
  #
  def ==(other)
    other.object_id == object_id or
      other.is_a?(self.class) && other.to_s == to_s
  end

  ##
  # Returns a plain vanilla proc that works just like other instances of Proc, the
  # only difference is that the binding of variables is the same as the serializable
  # proc, which is isolated.
  #
  #   x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
  #   s_proc = SerializableProc.new { [x, @x, @@x, $x].join(', ') }
  #   x, @x, @@x, $x = 'ly', 'iy', 'cy', 'gy'
  #   s_proc.to_proc.call # >> 'lx, ix, cx, gx'
  #
  # Just like any object that responds to #to_proc, you can do the following as well:
  #
  #   def action(&block) ; yield ; end
  #   action(&s_proc) # >> 'lx, ix, cx, gx'
  #
  def to_proc(binding = nil)
    if binding
      eval(@code[:runnable], @binding.eval!(binding), @file, @line)
    else
      @proc ||= eval(@code[:runnable], @binding.eval!, @file, @line)
    end
  end

  ##
  # Returns a string representation of itself, which is in fact the code enclosed within
  # the initializing block.
  #
  #   SerializableProc.new { [x, @x, @@x, $x].join(', ') }.to_s
  #   # >> lambda { [x, @x, @@x, $x].join(', ') }
  #
  # By specifying +debug+ as true, the true runnable code is returned, the only difference
  # from the above is that the variables within has been renamed (in order to provide for
  # variables isolation):
  #
  #   SerializableProc.new { [x, @x, @@x, $x].join(', ') }.to_s(true)
  #   # >> lambda { [lvar_x, ivar_x, cvar_x, gvar_x].join(', ') }
  #
  # The following renaming rules apply:
  # * local variable -> prefixed with 'lvar_',
  # * instance variable -> replaced '@' with 'ivar_'
  # * class variable -> replaced '@@' with 'cvar_'
  # * global variable -> replaced '$ with 'gvar_'
  #
  def to_s(debug = false)
    @code[debug ? :runnable : :extracted]
  end

  ##
  # Returns the number of arguments accepted when running #call. This is extracted directly
  # from the initializing code block, & is only as accurate as Proc#arity.
  #
  # Note that at the time of this writing, running on 1.8.* yields different result from
  # that of 1.9.*:
  #
  #   lambda { }.arity         # 1.8.* (-1) / 1.9.* (0)  (?!)
  #   lambda {|x| }.arity      # 1.8.* (1)  / 1.9.* (1)
  #   lambda {|x,y| }.arity    # 1.8.* (2)  / 1.9.* (2)
  #   lambda {|*x| }.arity     # 1.8.* (-1) / 1.9.* (-1)
  #   lambda {|x, *y| }.arity  # 1.8.* (-2) / 1.9.* (-2)
  #   lambda {|(x,y)| }.arity  # 1.8.* (1)  / 1.9.* (1)
  #
  def arity
    @arity
  end

  ##
  # Just like the vanilla proc, invokes it, setting params as specified. Since the code
  # representation of a SerializableProc is a lambda, expect lambda-like behaviour when
  # wrong number of params are passed in.
  #
  #   SerializableProc.new{|i| (['hello'] * i).join(' ') }.call(2)
  #   # >> 'hello hello'
  #
  def call(*params)
    if (binding = params[-1]).is_a?(::Binding)
      to_proc(binding).call(*params[0..-2])
    else
      to_proc.call(*params)
    end
  end

  alias_method :[], :call

  def binding #:nodoc:
    raise NotImplementedError
  end

end
