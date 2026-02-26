# frozen_string_literal: true

module Archon
  module FinalAnswer
    Result = Struct.new(:outcome, :value, :result_type, keyword_init: true)

    TOOL_SCHEMA = {
      type: :function,
      name: :final_answer,
      description: 'Return the final answer to the user. Call this when you have the answer.',
      parameters: {
        type: :object,
        properties: {
          outcome: {
            type: :string,
            enum: %i[success error overflow]
          },
          result_type: {
            type: :string,
            enum: %i[prose json uri]
          },
          value: {
            type: :string,
            description: 'The final answer value'
          }
        },
        required: %i[outcome value]
      }
    }.freeze

    def self.parse(arguments)
      args = arguments.is_a?(String) ? JSON.parse(arguments) : arguments
      Result.new(outcome: args['outcome'], value: args['value'], result_type: args['result_type'])
    end
  end
end
