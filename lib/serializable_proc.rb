require 'rubygems'
require 'forwardable'
require 'sourcify'
require 'ruby2ruby'
require 'sexp_processor'

require 'serializable_proc/marshalable'
require 'serializable_proc/isolatable'
require 'serializable_proc/binding'

##
# SerializableProc differs from the vanilla Proc in 2 ways:
#
# #1. Isolated variables
#
# By default, upon initializing, all variables (local, instance, class & global) within
# its context are extracted from the proc's binding, and are isolated from changes
# outside the proc's scope, thus, achieving a snapshot effect.
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
# It is possible to fine-tune how variables isolation is being applied by specifying :ignore 
# option to the constructor.
#
#   x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
#
#   s_proc = SerializableProc.new(ignore: :all) do
#     [x, @x, @@x, $x].join(', ')
#   end
#
#   x, @x, @@x, $x = 'ly', 'iy', 'cy', 'gy'
#
#   # Passing Kernel.binding is required to avoid nasty surprises
#   s_proc.call(binding) # >> "ly, iy, cy, gy"
#
# Supported values include :global, :class, :instance, :local & :all, with :all
# overriding all others. This can also be used as a workaround for variables that cannot
# be serialized:
#
#   SerializableProc.new(ignore: :global) do
#     $stdout << 'WAKE UP !!'        # global $stdout won't be isolated (avoid marshal error)
#   end
#
# You can also set :isolate option explicitly in the constructor to specify which variable 
# types should be isolated. The supported values as same as for the :ignore option. 
# The following will isolate only locals:
#
#  s_proc = SerializableProc.new(isolate: :local) do
#    ...
#  end
#
# Note that the :ignore option will be processed on top of the :isolate option. 
# The following will isolate only locals:
#
#  s_proc = SerializableProc.new(isolate: :all, ignore: [:global, :class, :instance]) do
#    ...
#  end
#
# Note that it is strongly-advised to append Kernel.binding as the last parameter when
# invoking the proc to avoid unnecessary nasty surprises. (see #call for more details)
#
# #2. Marshallable
#
# No throwing of TypeError when marshalling a SerializableProc:
#
#   Marshal.load(Marshal.dump(s_proc)).call # >> "lx, ix, cx, gx"
#   Marshal.load(Marshal.dump(v_proc)).call # >> TypeError (cannot dump Proc)
#
class SerializableProc

  include Isolatable
  include Marshalable
  marshal_attrs :file, :line, :codes, :arity, :binding, :sexps

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
  def initialize(options = {}, &block)
    @isolate, @ignore = options[:isolate], options[:ignore]
    e_code, e_sexp = block.to_source, block.to_sexp
    r_sexp, r_code = isolated_sexp_and_code(e_sexp)
    @arity, @file, @line = block.arity, *block.source_location
    @codes = {:extracted => e_code, :runnable => r_code}
    @sexps = {:extracted => e_sexp, :runnable => r_sexp}
    @binding = Binding.new(block.binding, r_sexp)
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
      eval(@codes[:runnable], @binding.eval!(binding), @file, @line)
    else
      @proc ||= eval(@codes[:runnable], @binding.eval!, @file, @line)
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
    @codes[debug ? :runnable : :extracted]
  end

  ##
  # Returns the sexp representation of this instance. By default, the sexp represents the
  # extracted code, if +debug+ specified as true, the runnable code version is returned.
  #
  #   SerializableProc.new { [x, @x, @@x, $x].join(', ') }.to_sexp
  #
  def to_sexp(debug = false)
    @sexps[debug ? :runnable : :extracted]
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
  # In the case where variables have been declared non-isolated with the :isolate/:ignore options,
  # invoking requires passing in +Kernel.binding+ as the last parameter avoid unexpected
  # surprises:
  #
  #   x, @x, @@x, $x = 'lx', 'ix', 'cx', 'gx'
  #   s_proc = SerializableProc.new(ignore: [:global, :class, :instance, :local]) do
  #     [x, @x, @@x, $x].join(', ')
  #   end
  #
  #   s_proc.call
  #   # >> raises NameError for x
  #   # >> @x is assumed nil (undefined)
  #   # >> raises NameError for @@x (actually this depends on if u are using 1.9.* or 1.8.*)
  #   # >> no issue with $x (since global is, after all, a global)
  #
  # To ensure expected results:
  #
  #   s_proc.call(binding) # >> 'lx, ix, cx, gx'
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
