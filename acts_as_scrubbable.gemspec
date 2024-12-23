$:.unshift File.expand_path('lib', __dir__)
require 'acts_as_scrubbable/version'

Gem::Specification.new do |s|
  s.name        = 'acts_as_scrubbable'
  s.version     = ActsAsScrubbable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Samer Masry']
  s.email       = ['samer.masry@gmail.com']
  s.homepage    = 'https://github.com/smasry/acts_as_scrubbable'
  s.summary     = %q{Scrubbing data made easy}
  s.description = %q{ActsAsScrubbable helps you scrub your database the easy way with mock data at the ActiveRecord level}
  s.license     = "MIT"
  s.required_ruby_version = ['>= 2.0', '< 4.0']

  s.add_runtime_dependency 'activesupport'    , '>= 6.1', '< 9'
  s.add_runtime_dependency 'activerecord'     , '>= 6.1', '< 9'
  s.add_runtime_dependency 'railties'         , '>= 6.1', '< 9'
  s.add_runtime_dependency 'faker'            , '>= 1.4'
  s.add_runtime_dependency 'highline'         , '>= 2.1.0'
  s.add_runtime_dependency 'term-ansicolor'   , '>= 1.3'
  s.add_runtime_dependency 'parallel'         , '>= 1.6'

  s.add_development_dependency 'rspec'        , '~> 3.3'
  s.add_development_dependency 'guard'        , '~> 2.13'
  s.add_development_dependency 'guard-rspec'  , '~> 4.6'
  s.add_development_dependency 'pry-byebug'   , '~> 3.2'
  s.add_development_dependency 'terminal-notifier-guard' , '~> 1.6'
  s.add_development_dependency 'activerecord-nulldb-adapter', '~> 1.0'
  s.add_development_dependency 'rspec_junit_formatter'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f).strip }
  s.require_paths = ['lib']
end
