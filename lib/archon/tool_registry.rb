# frozen_string_literal: true

module Archon
  class ToolRegistry
    attr_reader :tools

    def initialize
      @tools = { 'final_answer' => FinalAnswer::TOOL_SCHEMA }
    end

    def register(name, schema)
      @tools[name] = schema
    end

    def schemas
      @tools.values
    end

    def registered?(name)
      @tools.key?(name)
    end
  end
end
