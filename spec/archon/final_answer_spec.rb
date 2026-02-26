# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::FinalAnswer do
  describe '::TOOL_SCHEMA' do
    it 'defines a function tool schema' do
      expect(described_class::TOOL_SCHEMA[:type]).to eq(:function)
      expect(described_class::TOOL_SCHEMA[:name]).to eq(:final_answer)
    end
  end

  describe '.parse' do
    it 'parses a JSON string into a Result' do
      json = '{"outcome":"success","result_type":"prose","value":"42"}'
      result = described_class.parse(json)

      expect(result.outcome).to eq('success')
      expect(result.result_type).to eq('prose')
      expect(result.value).to eq('42')
    end

    it 'parses a hash into a Result' do
      result = described_class.parse(
        'outcome' => 'error', 'result_type' => 'json', 'value' => 'something broke'
      )

      expect(result.outcome).to eq('error')
      expect(result.result_type).to eq('json')
      expect(result.value).to eq('something broke')
    end
  end

  describe 'Result' do
    it 'has outcome, result_type, and value attributes' do
      result = described_class::Result.new(outcome: 'success', result_type: 'prose', value: 'hi')

      expect(result.outcome).to eq('success')
      expect(result.result_type).to eq('prose')
      expect(result.value).to eq('hi')
    end
  end
end
