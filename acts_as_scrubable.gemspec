$:.unshift File.expand_path('lib', __dir__)
require 'acts_as_scrubbable/version'

Gem::Specification.new do |s|
  s.name        = 'acts_as_scrubbable'
  s.version     = ActsAsScrubbable::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Samer Masry']
  s.email       = ['samer.masry@gmail.com']
  s.homepage    = ''
  s.summary     = %q{Scrubbing data made easy}
  s.description = %q{}
  s.required_ruby_version = '~> 2.0'

  s.add_runtime_dependency 'activesupport'    , '~> 4.1.13'
  s.add_runtime_dependency 'activerecord'     , '~> 4.1.13'
  s.add_runtime_dependency 'railties'         , '~> 4.1.13'
  s.add_runtime_dependency 'faker'            , '~> 1.4.3'
  s.add_runtime_dependency 'highline'         , '~> 1.7.8'
  s.add_runtime_dependency 'term-ansicolor'   , '~> 1.3.2'

  s.add_development_dependency 'rspec'        , '~> 3.3.0'
  s.add_development_dependency 'guard'        , '~> 2.13.0'
  s.add_development_dependency 'guard-rspec'  , '~> 4.6.4'
  s.add_development_dependency 'pry-byebug'   , '~> 3.2.0'
  s.add_development_dependency 'terminal-notifier-guard' , '~> 1.6.4'
  s.add_development_dependency 'activerecord-nulldb-adapter', '~> 0.3.1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f).strip }
  s.require_paths = ['lib']
end
