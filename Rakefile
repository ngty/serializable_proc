require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
    gem.name = "serializable_proc"
    gem.summary = %Q{Proc that can be serialized (as the name suggests)}
    gem.description = %Q{
      Give & take, serializing a ruby proc is possible, though not a perfect one.
      Requires either ParseTree (faster) or RubyParser (& Ruby2Ruby).
    }
    gem.email = "ngty77@gmail.com"
    gem.homepage = "http://github.com/ngty/serializable_proc"
    gem.authors = ["NgTzeYang"]
    gem.add_dependency "ruby2ruby", ">= 1.2.4"
    gem.add_development_dependency "bacon", ">= 0"
    # Plus one of the following groups:
    #
    # 1). ParseTree (better performance + dynamic goodness, but not supported on java & 1.9.*)
    # >> gem.add_dependency "ParseTree", ">= 3.0.5"
    #
    # 2). RubyParser (supported for all)
    # >> gem.add_dependency "ruby_parser", ">= 2.0.4"

    unless RUBY_PLATFORM =~ /java/i or RUBY_VERSION.include?('1.9.')
      gem.post_install_message = %Q{
 /////////////////////////////////////////////////////////////////////////////////

  ** SerializableProc **

  You are installing SerializableProc on a ruby platform & version that supports
  ParseTree. With ParseTree, u can enjoy better performance of SerializableProc,
  as well as other dynamic code analysis goodness, as compared to the default
  implementation using RubyParser's less flexible static code analysis.

  Anyway, u have been informed, SerializableProc will fallback on its default
  implementation using RubyParser.

 /////////////////////////////////////////////////////////////////////////////////
      }
    end
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |spec|
    spec.libs << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    spec.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :spec => :check_dependencies

begin
  require 'reek/adapters/rake_task'
  Reek::RakeTask.new do |t|
    t.fail_on_error = true
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  task :reek do
    abort "Reek is not available. In order to run reek, you must: sudo gem install reek"
  end
end

begin
  require 'roodi'
  require 'roodi_task'
  RoodiTask.new do |t|
    t.verbose = false
  end
rescue LoadError
  task :roodi do
    abort "Roodi is not available. In order to run roodi, you must: sudo gem install roodi"
  end
end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "serializable_proc #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
