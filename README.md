# Etcd::Lock

Ruby gem for coordinating exclusive jobs using etcd's atomic compare-and-swap feature.

https://coreos.com/etcd/docs/latest/api.html#atomic-compare-and-swap

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'etcd-lock'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install etcd-lock

## Usage

```ruby
# Initialize a new coordinator for my application
elc = Etcd::Lock::Coordinator.new('my-app')

# Perform some work, using a lock that lives for 10 seconds to
# ensure the job with not run anywhere else in that time period
elc.run_with_lock('my-job', 10) do
  perform_work
end

# Perform some work, using a lock that lives for 1 hour or
# until the job has finished running
elc.run_with_lock('my-other-job', 3600, remove: true) do
  perform_work
end
```
