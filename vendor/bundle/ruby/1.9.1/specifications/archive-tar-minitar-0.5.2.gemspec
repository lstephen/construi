# -*- encoding: utf-8 -*-
# stub: archive-tar-minitar 0.5.2 ruby lib

Gem::Specification.new do |s|
  s.name = "archive-tar-minitar"
  s.version = "0.5.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Austin Ziegler, Mauricio Ferna'ndez"]
  s.date = "2008-02-26"
  s.description = "Archive::Tar::Minitar is a pure-Ruby library and command-line utility that provides the ability to deal with POSIX tar(1) archive files. The implementation is based heavily on Mauricio Ferna'ndez's implementation in rpa-base, but has been reorganised to promote reuse in other projects."
  s.email = "minitar@halostatue.ca"
  s.executables = ["minitar"]
  s.extra_rdoc_files = ["README", "ChangeLog", "Install"]
  s.files = ["ChangeLog", "Install", "README", "bin/minitar"]
  s.homepage = "http://rubyforge.org/projects/ruwiki/"
  s.rdoc_options = ["--title", "Archive::Tar::MiniTar -- A POSIX tarchive library", "--main", "README", "--line-numbers"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.2")
  s.rubyforge_project = "ruwiki"
  s.rubygems_version = "2.4.6"
  s.summary = "Provides POSIX tarchive management from Ruby programs."

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version
end
