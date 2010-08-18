require File.join(File.dirname(__FILE__), '..', 'spec_helper')

class Otaky

  class MagicProc < ::SerializableProc ; end

  class << self
    def work(*args, &block)
      SerializableProc.new(&block)
    end
  end

end

shared 'has support for parsing Otaky.work (wo args)' do
  before { SerializableProc::Parsers::Static.matchers << 'Otaky\.work' }
  after { SerializableProc::Parsers::Static.matchers.clear }
end
