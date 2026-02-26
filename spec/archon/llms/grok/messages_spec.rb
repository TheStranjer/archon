# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::LLMs::Grok::Messages do
  describe '.build_request' do
    it 'builds a request body with messages and tools' do
      messages = [{ role: 'user', content: 'hello' }]
      tools = [Archon::FinalAnswer::TOOL_SCHEMA]

      body = described_class.build_request(
        model: 'grok-4-1-fast-reasoning', messages: messages, tools: tools
      )

      expect(body[:model]).to eq('grok-4-1-fast-reasoning')
      expect(body[:messages]).to eq(messages)
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
    it 'extracts message data from response body' do
      response_body = {
        'choices' => [{
          'message' => { 'role' => 'assistant', 'content' => 'hi', 'tool_calls' => nil },
          'finish_reason' => 'stop'
        }]
      }

      parsed = described_class.parse_response(response_body)

      expect(parsed[:role]).to eq('assistant')
      expect(parsed[:content]).to eq('hi')
      expect(parsed[:finish_reason]).to eq('stop')
    end

    it 'returns empty response for missing choices' do
      parsed = described_class.parse_response({ 'choices' => [] })

      expect(parsed[:role]).to eq('assistant')
      expect(parsed[:content]).to be_nil
    end
  end
end
