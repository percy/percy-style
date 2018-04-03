require 'spec_helper'
require 'rubocop'
require './lib/private_attribute_accessors'

describe RuboCop::Cop::Style::PrivateAttributeAccessors do
  subject(:cop) { described_class.new }

  # These helper methods are from https://github.com/bbatsov/rubocop/blob/4b26354497f32da8d771f35c66b2f47224f9674b/spec/support/cop_helper.rb#L10
  def inspect_source(cop, source, file = nil)
    if source.is_a?(Array) && source.size == 1
      fail "Don't use an array for a single line of code: #{source}"
    end
    RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
    processed_source = parse_source(source, file)
    fail 'Error parsing example code' unless processed_source.valid_syntax?
    _investigate(cop, processed_source)
  end

  def parse_source(source, file = nil)
    source = source.join($RS) if source.is_a?(Array)

    if file && file.respond_to?(:write)
      file.write(source)
      file.rewind
      file = file.path
    end

    RuboCop::ProcessedSource.new(source, 2.3, file)
  end

  def _investigate(cop, processed_source)
    forces = RuboCop::Cop::Force.all.each_with_object([]) do |klass, instances|
      next unless cop.join_force?(klass)
      instances << klass.new([cop])
    end

    commissioner =
      RuboCop::Cop::Commissioner.new([cop], forces, raise_error: true)
    commissioner.investigate(processed_source)
    commissioner
  end

  it 'registers an offense for using any attr_* methods in private scope' do
    inspect_source cop, <<-RUBY.strip_indent
        class SmallThing < Thing
        private
          attr_reader :anything
          attr_writer :something
          attr_accessor :nothing
        end
    RUBY

    expect(cop.offenses.size).to eq(3)
    expect(cop.offenses.map(&:message))
      .to eq(['Do not use private attribute accessors',
              'Do not use private attribute accessors',
              'Do not use private attribute accessors'])
  end

  it 'isn\'t offend by using any attr_* methods in public scope' do
    inspect_source cop, <<-RUBY.strip_indent
        class SmallThing < Thing
          attr_reader :anything
          attr_writer :something
          attr_accessor :nothing
        end
    RUBY

    expect(cop.offenses.size).to eq(0)
  end
end
