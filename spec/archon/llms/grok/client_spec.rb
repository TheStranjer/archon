# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::LLMs::Grok::Client do
  subject(:client) { described_class.new(api_key: 'test-key', model: 'grok-4-1-fast-reasoning') }

  let(:api_url) { 'https://api.x.ai/v1/chat/completions' }

  describe '#chat' do
    let(:messages) { [{ role: 'user', content: 'hello' }] }
    let(:tools) { [Archon::FinalAnswer::TOOL_SCHEMA] }
    let(:response_body) do
      {
        'choices' => [{
          'message' => {
            'role' => 'assistant',
            'content' => 'Hello!',
            'tool_calls' => nil
          },
          'finish_reason' => 'stop'
        }]
      }
    end

    before do
      stub_request(:post, api_url)
        .to_return(
          status: 200,
          body: JSON.generate(response_body),
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'sends a POST request and returns parsed response' do
      result = client.chat(messages: messages, tools: tools)

      expect(result[:role]).to eq('assistant')
      expect(result[:content]).to eq('Hello!')
    end

    it 'sends the authorization header' do
      client.chat(messages: messages, tools: tools)

      expect(WebMock).to have_requested(:post, api_url)
        .with(headers: { 'Authorization' => 'Bearer test-key' })
    end
  end
end
