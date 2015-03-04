# Kleisli.run

Provides a ruby version of do-notation syntax for the monads provided in the
[Kleisli](https://github.com/txus/kleisli) gem.

More concise than nested fmap/binds, more readable (to me) than point-free syntax

## Installation

Add this line to your application's Gemfile:

    gem 'kleisli-run'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kleisli-run

## Usage

With this gem installed, you can map over a bunch of dependent monads to
work with their inner values using a concise procedural syntax. Plenty more
examples in the tests, but here's a few basic illustrations:

```ruby
Kleisli.run do
  a from: Success(1)
  b from: Success(2)
  a + b
end
# Success(3)

Kleisli.run do
  a from: Failure(["not gonna happen here"])
  b from: Success(2)
  c from: Success(5)
  a + b + c
end
# Failure(["not gonna happen here"])
# note - nothing after the first line of the block is executed
```
A few notes about the behavior within a block

  * Extract values from monads using the variable from: Monad(value) syntax
    * You can use method calls for the from: value, as long as they return a monad
  * Inline assignment is possible eg: a = somevalue, and somevalue does not have
      to be a monad, however you must call from: on at least one monad inside a
      block
  * Methods and values from the scope in which the block is created are given
    precedence, so you cannot name values inside the block after any names
    that exist in the scope where you define the block

## Contributing

1. Fork it ( http://github.com/<my-github-username>/kleisli-run/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
