# percy-style

Percy shared style configs.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test, :development do
  gem 'percy-style'
end
```

Or, for a Ruby library, add this to your gemspec:

```ruby
spec.add_development_dependency 'percy-style'
```

And then run:

```bash
$ bundle install
```

## Usage

Create a `.rubocop.yml` with the following directives:

```yaml
inherit_gem:
  percy-style:
    - default.yml
```

Now, run:

```bash
$ bundle exec rubocop
```

You do not need to include rubocop directly in your application's dependencies. Percy-style will include a specific version of `rubocop` and `rubocop-rspec` that is shared across all projects.
