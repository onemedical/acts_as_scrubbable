# ActsAsScrubbable

Scrubbing made easy

Acts as scrubbable give you model level access to scrub your data per object


## Installation

```ruby
gem 'acts_as_scrubbable'
```

## Usage

Simple add the configuration for your fields that map directly to your columns


```ruby
class User < ActiveRecord::Base
  ...

  acts_as_scrubbable :first_name, :last_name

  ...
end
```


Incase the mapping is not straight forward

```ruby
class Address
  acts_as_scrubbable :lng => :longitude, :lat => :latitude
end
```
