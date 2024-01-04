source 'https://rubygems.org'

gemspec

# Lock Rails down in the matrix build, but not by default
rails_version_prefix = ENV.fetch("RAILS_VERSION_PREFIX", nil)
if rails_version_prefix == "main"
  gem "activesupport", github: "rails/rails", branch: "main"
  gem "activerecord", github: "rails/rails", branch: "main"
  gem "railties", github: "rails/rails", branch: "main"
elsif rails_version_prefix
  gem "activesupport", "~> #{rails_version_prefix}.0"
  gem "activerecord", "~> #{rails_version_prefix}.0"
  gem "railties", "~> #{rails_version_prefix}.0"
end
