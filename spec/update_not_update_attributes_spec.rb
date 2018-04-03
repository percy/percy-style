require 'spec_helper'
require 'rubocop'
require './lib/update_not_update_attributes'

describe RuboCop::Cop::Style::UpdateNotUpdateAttributes do
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

  def autocorrect_source(cop, source, file = nil)
    cop.instance_variable_get(:@options)[:auto_correct] = true
    processed_source = parse_source(source, file)
    _investigate(cop, processed_source)

    corrector =
      RuboCop::Cop::Corrector.new(processed_source.buffer, cop.corrections)
    corrector.rewrite
  end
  # end helper methods

  context 'with no exceptions' do
    [
      'user.update full_name: "joe"',
      'user.update! email: "joe@email.com"',
    ].each do |source|
      it "isn't offended by update or update!" do
        cop = described_class.new
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(0)
      end
    end
  end

  context 'with exceptions' do
    [
      'user.update_attributes full_name: "joe"',
      'user.update_attributes! full_name: "joe"',
      'user.dog.update_attributes full_name: "joe"',
      'user.dog.update_attributes! full_name: "joe"',
      ['users.each do |user|', 'user.update_attributes email: "joe@email.com"', 'end'],
      ['users.each do |user|', 'user.campaign.update_attributes email: "joe@email.com"', 'end'],
      ['users.each do |user|', 'user.update_attributes! email: "joe@email.com"', 'end'],
      ['users.each do |user|', 'user.campaign.update_attributes! email: "joe@email.com"', 'end'],
    ].each do |source|
      it "is offended by source `#{source}`" do
        cop = described_class.new
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(1)
      end
    end
  end

  context 'auto-corrects' do
    it 'update_attributes to update' do
      cop = described_class.new
      new_source = autocorrect_source(cop, 'user.update_attributes full_name: "joe"')
      expect(new_source).to eq('user.update full_name: "joe"')
    end

    it 'update_attributes! to update!' do
      cop = described_class.new
      new_source = autocorrect_source(cop, 'user.update_attributes! full_name: "joe"')
      expect(new_source).to eq('user.update! full_name: "joe"')
    end
  end
end
