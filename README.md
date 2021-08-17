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

Simple add the configuration for your fields that map directly to your columns


```ruby
class User < ActiveRecord::Base
  ...

  acts_as_scrubbable :first_name, :last_name


  # optionally you can add a scope to limit the rows to update
  scope :scrubbable_scope, -> { where(some_value: true) }

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

### UPDATE VS UPSERT

By default, the scrubbing proces will run independent UPDATE statements for each scrubbed model. This can be time 
consuming if you are scrubbing a large number of records.  As an alternative, some 
databases support doing bulk database updates using an upsert using the INSERT command.  `activerecord-import` 
gives us easy support for this and as such it is a requirement to using
this feature. Some details about the implementation can be found here. https://github.com/zdennis/activerecord-import#duplicate-key-update

Note that we only support the MySQL implementation at this time.

To use UPSERT over UPDATE, it can be enabled by specifying the environment variable `USE_UPSERT='true'` or through configuration.

```ruby
ActsAsScrubbable.configure do |c|
  c.use_upsert = true
end
```

