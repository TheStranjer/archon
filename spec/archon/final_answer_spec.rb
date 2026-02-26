# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::FinalAnswer do
  describe '::TOOL_SCHEMA' do
    it 'defines a function tool schema' do
      expect(described_class::TOOL_SCHEMA[:type]).to eq('function')
      expect(described_class::TOOL_SCHEMA[:function][:name]).to eq('final_answer')
    end
  end

  describe '.parse' do
    it 'parses a JSON string into a Result' do
      json = '{"outcome":"success","value":"42"}'
      result = described_class.parse(json)

      expect(result.outcome).to eq('success')
      expect(result.value).to eq('42')
    end

    it 'parses a hash into a Result' do
      result = described_class.parse('outcome' => 'error', 'value' => 'something broke')

      expect(result.outcome).to eq('error')
      expect(result.value).to eq('something broke')
    end
  end

  describe 'Result' do
    it 'has outcome and value attributes' do
      result = described_class::Result.new(outcome: 'success', value: 'hello')

      expect(result.outcome).to eq('success')
      expect(result.value).to eq('hello')
    end
  end
end
