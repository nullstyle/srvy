# Srvy
[![Code Climate](https://codeclimate.com/github/nullstyle/srvy.png)](https://codeclimate.com/github/nullstyle/srvy)

A ruby gem to integration SRV-based service discovery into your application

## Installation

Add this line to your application's Gemfile:

    gem 'srvy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install srvy

## Usage

```ruby
$srvy = Srvy::Resolver.new # default configuration, using the locally configured resolver

# picks a single server by randomized with weight in the highest priority group
$srvy.get_single("db-slaves.mydomain.com") # => "mysql01.mydomain.com:3306"

# to get all services in the highest priority group 
$srvy.get_many("memcache.mydomain.com") # => ["memcache01.mydomain.com:11211", "memcache02.mydomain.com:11211"]

# get all records, including lower priority (e.g. backup) services
$srvy.get_all("db.mydomain.com") # => ["db01.mydomain.com:3306", "db01-failover.mydomain.com:3306"]

```

#TODO

I havent currently thought of a good api to signal to Srvy that you want to use lower priority services... currently the only way is to use `get_all` and pick the services out yourself.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
