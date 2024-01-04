source 'https://rubygems.org'

gemspec

# Lock Rails down in the matrix build, but not by default
gem "activesupport", ENV.fetch("RAILS_VERSION", nil)
gem "activerecord", ENV.fetch("RAILS_VERSION", nil)
gem "railties", ENV.fetch("RAILS_VERSION", nil)
