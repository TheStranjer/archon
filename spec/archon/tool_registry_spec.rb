# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::ToolRegistry do
  subject(:registry) { described_class.new }

  describe '#initialize' do
    it 'includes final_answer by default' do
      expect(registry.registered?('final_answer')).to be true
    end
  end

  describe '#register' do
    it 'adds a new tool' do
      schema = { type: 'function', function: { name: 'test' } }
      registry.register('test', schema)

      expect(registry.registered?('test')).to be true
    end
  end

  describe '#schemas' do
    it 'returns all tool schemas' do
      expect(registry.schemas).to contain_exactly(Archon::FinalAnswer::TOOL_SCHEMA)
    end

    it 'includes newly registered tools' do
      schema = { type: 'function', function: { name: 'test' } }
      registry.register('test', schema)

      expect(registry.schemas.length).to eq(2)
    end
  end
end
