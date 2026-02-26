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
            input: messages,
            tool_choice: :required
          }
          body[:tools] = all_tools unless all_tools.empty?
          body
        end

        def self.parse_response(response_body)
          output = response_body['output'] || []
          content = extract_content(output)
          tool_calls = extract_tool_calls(output)

          {
            role: 'assistant',
            content: content,
            tool_calls: tool_calls.empty? ? nil : tool_calls,
            finish_reason: response_body['status'] == 'completed' ? 'stop' : 'tool_calls'
          }
        end

        def self.extract_content(output)
          texts = output.filter_map do |item|
            next unless item['type'] == 'message'

            item['content']&.filter_map do |block|
              block['text'] if %w[text output_text].include?(block['type'])
            end&.join
          end
          combined = texts.join
          combined.empty? ? nil : combined
        end

        def self.extract_tool_calls(output)
          output.select { |item| item['type'] == 'function_call' }.map do |item|
            {
              'id' => item['call_id'],
              'function' => { 'name' => item['name'], 'arguments' => item['arguments'] }
            }
          end
        end

        private_class_method :extract_content, :extract_tool_calls
      end
    end
  end
end
