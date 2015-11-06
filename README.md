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


### To run
```
rake scrub

....
Type SCRUB to continue.
SCRUB
W, [2015-11-05T14:09:20.900771 #64194]  WARN -- : Scrubbing classes
I, [2015-11-05T14:09:24.228012 #64194]  INFO -- : Scrubbing ClassToScrub
...
I, [2015-11-05T14:09:25.615155 #64194]  INFO -- : Scrub Complete!

```


### Extending

You may find the need to extend or add additional generators or an after_hook

```ruby
ActsAsScrubbable.configure do |c|
  c.add :email_with_prefix, -> { "prefix-#{Faker::Internet.email}" }

  c.after_hook do
    puts "Running after commit"
    ActiveRecord::Base.connection.execute("SELECT * FROM FOO")
  end
end
```
