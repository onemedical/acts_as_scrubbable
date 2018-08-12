# ActsAsScrubbable

Scrubbing made easy

Acts as scrubbable give you model level access to scrub your data per object.

It runs using the parallel gem for faster processing which is dependent on the
amount of cores available on the box.  *More cores == faster scrubbing*


## Installation

```ruby
gem 'acts_as_scrubbable'
```

## Usage

Add the configuration for your fields that map directly to your columns and a scrub_type
for those columns.

Default Scrub types include:
- `scrub` - scrub the field's value based on it's name or mapping (see mapping case below)
- `skip` - do not scrub the field's value
- `wipe` - set the field's value to nil on scrub
- `sterilize` - delete all records for this model on scrub

```ruby
class ScrubExample < ActiveRecord::Base
  ...

  acts_as_scrubbable :scrub, :first_name # first_name will be random after `scrub!`
  acts_as_scrubbable :skip, :middle_name # middle_name will be original value after `scrub!`
  acts_as_scrubbable :wipe, :last_name # last_name will be `nil` after `scrub!`


  # optionally you can add a scope to limit the rows to update
  scope :scrubbable_scope, -> { where(some_value: true) }

  ...
end

class SterilizeExample < ActiveRecord::Base
  acts_as_scrubbable :sterilize # table will contain no records after `scrub!`
end

```


Incase the mapping is not straight forward

```ruby
class Address
  acts_as_scrubbable :scrub, :lng => :longitude, :lat => :latitude
end
```

### To run

The confirmation message will be the db host

```
rake scrub

....
2015-11-19 10:52:51 -0800: [WARN] - Please verify the information below to continue
2015-11-19 10:52:51 -0800: [WARN] - Host:  127.0.0.1
2015-11-19 10:52:51 -0800: [WARN] - Database: blog_development
Type '127.0.0.1' to continue.
-> 127.0.0.1
2015-11-19 10:52:51 -0800: [WARN] -- : Scrubbing classes
2015-11-19 10:52:51 -0800: [WARN] -- : Scrubbing ClassToScrub
...
2015-11-19 10:52:51 -0800: [WARN] -- : Scrub Complete!

```

In the case you are automating the rake task and want to skip the confirmation

```
rake scrub SKIP_CONFIRM=true
```

If you want to limit the classes you to be scrubbed you can set the `SCRUB_CLASSES` variable

```
rake scrub SCRUB_CLASSES=Blog,Post
```

If you want to skip the afterhook

```
rake scrub SKIP_AFTERHOOK=true
```



### Extending

You may find the need to extend or add additional generators or an after_hook

```ruby
ActsAsScrubbable.configure do |c|
  c.add :email_with_prefix, -> { "prefix-#{Faker::Internet.email}" }

  c.after_hook do
    puts "Running after commit"
    ActiveRecord::Base.connection.execute("TRUNCATE some_table")
  end
end
```
