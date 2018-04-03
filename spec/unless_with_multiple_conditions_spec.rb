require 'spec_helper'
require 'rubocop'
require './lib/unless_with_multiple_conditions'

describe RuboCop::Cop::Style::UnlessWithMultipleConditions do
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

  it "isn't offended by single conditions, if statements with multiple conditions" do
    [
      ['if(:foo)', 'end'],
      ['unless(:foo)', 'end'],
      ['if(:foo || :bar)', 'end'],
      ['if(:foo && :bar)', 'end'],
    ].each do |source|
      cop = described_class.new
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  it 'is offended by unless statements with multiple conditions' do
    [
      ['unless :foo && :bar', 'end'],
      ['unless :foo and :bar', 'end'],
      ['unless :foo || :bar', 'end'],
      ['unless :foo or :bar', 'end'],
    ].each do |source|
      cop = described_class.new
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end
end
