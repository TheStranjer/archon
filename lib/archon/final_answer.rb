# frozen_string_literal: true

module Archon
  module FinalAnswer
    Result = Struct.new(:outcome, :value, keyword_init: true)

    TOOL_SCHEMA = {
      type: 'function',
      function: {
        name: 'final_answer',
        description: 'Return the final answer to the user. Call this when you have the answer.',
        parameters: {
          type: 'object',
          properties: {
            outcome: {
              type: 'string',
              description: 'The outcome status: "success", "error", or "overflow"'
            },
            value: {
              type: 'string',
              description: 'The final answer value'
            }
          },
          required: %w[outcome value]
        }
      }
    }.freeze

    def self.parse(arguments)
      args = arguments.is_a?(String) ? JSON.parse(arguments) : arguments
      Result.new(outcome: args['outcome'], value: args['value'])
    end
  end
end
