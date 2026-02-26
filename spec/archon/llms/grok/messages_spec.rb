# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::LLMs::Grok::Messages do
  describe '.build_request' do
    it 'builds a request body with input and tools' do
      messages = [{ role: 'user', content: 'hello' }]
      tools = [Archon::FinalAnswer::TOOL_SCHEMA]

      body = described_class.build_request(
        model: 'grok-4-1-fast-reasoning', messages: messages, tools: tools
      )

      expect(body[:model]).to eq('grok-4-1-fast-reasoning')
      expect(body[:input]).to eq(messages)
      expect(body[:tools]).to include(*tools)
      expect(body[:tools]).to include({ type: 'web_search' }, { type: 'x_search' })
    end

    it 'includes web_search and x_search tools by default' do
      body = described_class.build_request(
        model: 'grok-4-1-fast-reasoning', messages: [], tools: []
      )

      expect(body[:tools]).to include({ type: 'web_search' }, { type: 'x_search' })
    end

    it 'omits web_search when disabled' do
      body = described_class.build_request(
        model: 'grok-4-1-fast-reasoning', messages: [], tools: [], web_search: false
      )

      expect(body[:tools]).not_to include({ type: 'web_search' })
      expect(body[:tools]).to include({ type: 'x_search' })
    end

    it 'omits x_search when disabled' do
      body = described_class.build_request(
        model: 'grok-4-1-fast-reasoning', messages: [], tools: [], x_search: false
      )

      expect(body[:tools]).to include({ type: 'web_search' })
      expect(body[:tools]).not_to include({ type: 'x_search' })
    end

    it 'omits tools key when all tools are empty and search is disabled' do
      body = described_class.build_request(
        model: 'grok-4-1-fast-reasoning', messages: [], tools: [],
        web_search: false, x_search: false
      )

      expect(body).not_to have_key(:tools)
    end
  end

  describe '.parse_response' do
    it 'extracts text content from response output' do
      response_body = {
        'status' => 'completed',
        'output' => [{
          'type' => 'message',
          'content' => [{ 'type' => 'output_text', 'text' => 'hi' }]
        }]
      }

      parsed = described_class.parse_response(response_body)

      expect(parsed[:role]).to eq('assistant')
      expect(parsed[:content]).to eq('hi')
      expect(parsed[:tool_calls]).to be_nil
      expect(parsed[:finish_reason]).to eq('stop')
    end

    it 'extracts function calls from response output' do
      response_body = {
        'status' => 'incomplete',
        'output' => [{
          'type' => 'function_call', 'call_id' => 'call_1',
          'name' => 'final_answer', 'arguments' => '{"outcome":"success","value":"42"}'
        }]
      }
      parsed = described_class.parse_response(response_body)
      expected_call = {
        'id' => 'call_1',
        'function' => { 'name' => 'final_answer',
                        'arguments' => '{"outcome":"success","value":"42"}' }
      }

      expect(parsed[:tool_calls]).to contain_exactly(expected_call)
      expect(parsed[:finish_reason]).to eq('tool_calls')
    end

    it 'returns empty response for missing output' do
      parsed = described_class.parse_response({ 'status' => 'completed' })

      expect(parsed[:role]).to eq('assistant')
      expect(parsed[:content]).to be_nil
    end
  end
end
