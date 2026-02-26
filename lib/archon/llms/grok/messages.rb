# frozen_string_literal: true

module Archon
  module LLMs
    module Grok
      class Messages
        def self.build_request(model:, messages:, tools:, web_search: true, x_search: true)
          all_tools = tools.dup
          all_tools << { type: 'web_search' } if web_search
          all_tools << { type: 'x_search' } if x_search

          body = {
            model: model,
            messages: messages
          }
          body[:tools] = all_tools unless all_tools.empty?
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
