# frozen_string_literal: true

require 'json'

module Archon
  class Agent
    attr_reader :registry, :client, :overflow

    def initialize(client:, overflow: 10)
      @client = client
      @overflow = overflow
      @registry = ToolRegistry.new
    end

    def run(prompt)
      messages = [{ role: 'user', content: prompt }]
      tool_call_count = 0

      loop do
        response = client.chat(messages: messages, tools: registry.schemas)
        messages << build_assistant_message(response)
        tool_call_count += count_tool_calls(response)

        return handle_overflow if tool_call_count >= overflow

        result = handle_response(response, messages)
        return result if result
      end
    end

    private

    def build_assistant_message(response)
      msg = { role: 'assistant', content: response[:content] }
      msg[:tool_calls] = response[:tool_calls] if response[:tool_calls]
      msg
    end

    def handle_response(response, messages)
      return handle_empty if empty_response?(response)
      return content_as_result(response[:content]) unless response[:tool_calls]

      process_tool_calls(response, messages)
    end

    def count_tool_calls(response)
      response[:tool_calls]&.length || 0
    end

    def process_tool_calls(response, messages)
      return nil unless response[:tool_calls]

      response[:tool_calls].each do |tool_call|
        result = handle_tool_call(tool_call, messages)
        return result if result
      end
      nil
    end

    def handle_tool_call(tool_call, messages)
      name = tool_call.dig('function', 'name')
      args = tool_call.dig('function', 'arguments')
      return FinalAnswer.parse(args) if name == 'final_answer'

      messages << tool_result(tool_call['id'], execute_tool(name))
      nil
    end

    def execute_tool(name)
      return "Unknown tool: #{name}" unless registry.registered?(name)

      "Tool #{name} executed"
    end

    def tool_result(tool_call_id, content)
      { role: 'tool', tool_call_id: tool_call_id, content: content }
    end

    def content_as_result(content)
      FinalAnswer::Result.new(outcome: 'success', result_type: 'prose', value: content)
    end

    def empty_response?(response)
      response[:content].nil? && response[:tool_calls].nil?
    end

    def handle_empty
      FinalAnswer::Result.new(outcome: 'error', value: 'Empty response from LLM')
    end

    def handle_overflow
      FinalAnswer::Result.new(outcome: 'overflow', value: 'Tool call limit reached')
    end
  end
end
