# -*- encoding: utf-8 -*-
# stub: codeclimate-test-reporter 0.4.7 ruby lib

Gem::Specification.new do |s|
  s.name = "codeclimate-test-reporter"
  s.version = "0.4.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Bryan Helmkamp"]
  s.date = "2015-02-26"
  s.description = "Collects test coverage data from your Ruby test suite and sends it to Code Climate's hosted, automated code review service. Based on SimpleCov."
  s.email = ["bryan@brynary.com"]
  s.executables = ["cc-tddium-post-worker"]
  s.files = ["bin/cc-tddium-post-worker"]
  s.homepage = ""
  s.licenses = ["MIT"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9")
  s.rubygems_version = "2.4.6"
  s.summary = "Uploads Ruby test coverage data to Code Climate."

  s.installed_by_version = "2.4.6" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<simplecov>, ["< 1.0.0", ">= 0.7.1"])
      s.add_development_dependency(%q<bundler>, ["~> 1.3"])
      s.add_development_dependency(%q<rake>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<artifice>, [">= 0"])
      s.add_development_dependency(%q<pry>, [">= 0"])
    else
      s.add_dependency(%q<simplecov>, ["< 1.0.0", ">= 0.7.1"])
      s.add_dependency(%q<bundler>, ["~> 1.3"])
      s.add_dependency(%q<rake>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<artifice>, [">= 0"])
      s.add_dependency(%q<pry>, [">= 0"])
    end
  else
    s.add_dependency(%q<simplecov>, ["< 1.0.0", ">= 0.7.1"])
    s.add_dependency(%q<bundler>, ["~> 1.3"])
    s.add_dependency(%q<rake>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<artifice>, [">= 0"])
    s.add_dependency(%q<pry>, [">= 0"])
  end
end
