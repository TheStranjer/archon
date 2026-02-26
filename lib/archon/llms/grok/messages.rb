# frozen_string_literal: true

module Archon
  module LLMs
    module Grok
      class Messages
        def self.build_request(model:, messages:, tools:)
          body = {
            model: model,
            messages: messages
          }
          body[:tools] = tools unless tools.empty?
          body
        end

        def self.parse_response(response_body)
          choice = response_body.dig('choices', 0)
          return empty_response if choice.nil?

          message = choice['message']
          {
            role: message['role'],
            content: message['content'],
            tool_calls: message['tool_calls'],
            finish_reason: choice['finish_reason']
          }
        end

        def self.empty_response
          { role: 'assistant', content: nil, tool_calls: nil, finish_reason: 'stop' }
        end
      end
    end
  end
end
