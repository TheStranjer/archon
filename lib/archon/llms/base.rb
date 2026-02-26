# frozen_string_literal: true

module Archon
  module LLMs
    class Base
      def chat(messages:, tools:)
        raise NotImplementedError, "#{self.class}#chat must be implemented"
      end
    end
  end
end
