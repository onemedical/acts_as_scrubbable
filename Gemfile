source 'https://rubygems.org'

gemspec

# Lock Rails down in the matrix build, but not by default
rails_version = ENV.fetch("RAILS_VERSION", nil)
if rails_version == "main"
  gem "activesupport", github: "rails/rails", branch: "main"
  gem "activerecord", github: "rails/rails", branch: "main"
  gem "railties", github: "rails/rails", branch: "main"
elsif rails_version
  gem "activesupport", rails_version
  gem "activerecord", rails_version
  gem "railties", rails_version
end
