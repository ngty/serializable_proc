# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{serializable_proc}
  s.version = "0.4.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["NgTzeYang"]
  s.date = %q{2010-09-23}
  s.description = %q{
      Give & take, serializing a ruby proc is possible, though not a perfect one (yet).
    }
  s.email = %q{ngty77@gmail.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    ".document",
     ".gitignore",
     "HISTORY.txt",
     "LICENSE",
     "README.rdoc",
     "Rakefile",
     "VERSION",
     "lib/serializable_proc.rb",
     "lib/serializable_proc/binding.rb",
     "lib/serializable_proc/fixes.rb",
     "lib/serializable_proc/isolatable.rb",
     "lib/serializable_proc/marshalable.rb",
     "serializable_proc.gemspec",
     "spec/bounded_vars/class_vars_spec.rb",
     "spec/bounded_vars/class_vars_within_block_scope_spec.rb",
     "spec/bounded_vars/errors_spec.rb",
     "spec/bounded_vars/global_vars_spec.rb",
     "spec/bounded_vars/global_vars_within_block_scope_spec.rb",
     "spec/bounded_vars/instance_vars_spec.rb",
     "spec/bounded_vars/instance_vars_within_block_scope_spec.rb",
     "spec/bounded_vars/local_vars_spec.rb",
     "spec/bounded_vars/local_vars_within_block_scope_spec.rb",
     "spec/code_block/magic_vars_spec.rb",
     "spec/code_block/renaming_vars_spec.rb",
     "spec/proc_like/extras_spec.rb",
     "spec/proc_like/invoking_with_args_spec.rb",
     "spec/proc_like/invoking_with_class_vars_spec.rb",
     "spec/proc_like/invoking_with_global_vars_spec.rb",
     "spec/proc_like/invoking_with_instance_vars_spec.rb",
     "spec/proc_like/invoking_with_local_vars_spec.rb",
     "spec/proc_like/marshalling_spec.rb",
     "spec/proc_like/others_spec.rb",
     "spec/spec_helper.rb"
  ]
  s.homepage = %q{http://github.com/ngty/serializable_proc}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Proc that can be serialized (as the name suggests)}
  s.test_files = [
    "spec/proc_like/extras_spec.rb",
     "spec/proc_like/invoking_with_local_vars_spec.rb",
     "spec/proc_like/invoking_with_instance_vars_spec.rb",
     "spec/proc_like/invoking_with_class_vars_spec.rb",
     "spec/proc_like/invoking_with_args_spec.rb",
     "spec/proc_like/others_spec.rb",
     "spec/proc_like/invoking_with_global_vars_spec.rb",
     "spec/proc_like/marshalling_spec.rb",
     "spec/code_block/magic_vars_spec.rb",
     "spec/code_block/renaming_vars_spec.rb",
     "spec/bounded_vars/global_vars_within_block_scope_spec.rb",
     "spec/bounded_vars/instance_vars_within_block_scope_spec.rb",
     "spec/bounded_vars/errors_spec.rb",
     "spec/bounded_vars/local_vars_within_block_scope_spec.rb",
     "spec/bounded_vars/class_vars_spec.rb",
     "spec/bounded_vars/local_vars_spec.rb",
     "spec/bounded_vars/global_vars_spec.rb",
     "spec/bounded_vars/instance_vars_spec.rb",
     "spec/bounded_vars/class_vars_within_block_scope_spec.rb",
     "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<sourcify>, [">= 0.2.2.1"])
      s.add_runtime_dependency(%q<ruby2ruby>, [">= 1.2.5"])
      s.add_runtime_dependency(%q<sexp_processor>, [">= 3.0.5"])
      s.add_development_dependency(%q<bacon>, [">= 0"])
    else
      s.add_dependency(%q<sourcify>, [">= 0.2.2.1"])
      s.add_dependency(%q<ruby2ruby>, [">= 1.2.5"])
      s.add_dependency(%q<sexp_processor>, [">= 3.0.5"])
      s.add_dependency(%q<bacon>, [">= 0"])
    end
  else
    s.add_dependency(%q<sourcify>, [">= 0.2.2.1"])
    s.add_dependency(%q<ruby2ruby>, [">= 1.2.5"])
    s.add_dependency(%q<sexp_processor>, [">= 3.0.5"])
    s.add_dependency(%q<bacon>, [">= 0"])
  end
end

