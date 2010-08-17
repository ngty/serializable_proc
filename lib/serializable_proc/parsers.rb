class SerializableProc
  module Parsers
    RUBY_2_RUBY = Ruby2Ruby.new
    RUBY_PARSER = RubyParser.new
  end
end

require 'serializable_proc/parsers/pt'
require 'serializable_proc/parsers/rp'
