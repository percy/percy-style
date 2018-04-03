# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "charity_water/style/version"

Gem::Specification.new do |spec|
  spec.name          = "cw-style"
  spec.version       = CharityWater::Style::VERSION
  spec.authors       = ["charity: water"]
  spec.email         = ["team@charitywater.org"]

  spec.summary       = 'charity: water style guides and shared style configs.'
  spec.homepage      = 'https://github.com/charitywater/cw-style'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rubocop", "= 0.49.1"
  spec.add_dependency "rubocop-rspec-focused", "= 0.0.3"
  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
