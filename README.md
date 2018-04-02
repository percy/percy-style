# cw-style

charity: water shared code style configs for RuboCop. Forked from https://github.com/percy/percy-style.

## Installation

Add this line to your application's Gemfile:

```ruby
group :test, :development do
  gem 'cw-style'
end
```

Or, for a Ruby library, add this to your gemspec:

```ruby
spec.add_development_dependency 'cw-style'
```

And then run:

```bash
$ bundle install
```

## Usage

Create a `.rubocop.yml` with the following directives:

```yaml
inherit_gem:
  cw-style:
    - default.yml
```

Now, run:

```bash
$ bundle exec rubocop
```

You do not need to include rubocop directly in your application's dependencies. Cw-style will include a specific version of `rubocop` and `rubocop-rspec` that is shared across all projects.
