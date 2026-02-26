# frozen_string_literal: true

require 'faraday'
require 'json'

module Archon
  module LLMs
    module Grok
      class Client < Base
        API_URL = 'https://api.x.ai/v1/chat/completions'

        def initialize(
          api_key: ENV.fetch('XAI_API_KEY'),
          model: 'grok-4-1-fast-reasoning',
          web_search: true,
          x_search: true
        )
          super()
          @api_key = api_key
          @model = model
          @web_search = web_search
          @x_search = x_search
          @conn = build_connection
        end

        def chat(messages:, tools:)
          body = Messages.build_request(
            model: @model, messages: messages, tools: tools,
            web_search: @web_search, x_search: @x_search
          )
          response = post_request(body)
          Messages.parse_response(response.body)
        end

        private

        def build_connection
          Faraday.new(url: API_URL) do |f|
            f.request :json
            f.response :json
          end
        end

        def post_request(body)
          @conn.post do |req|
            req.headers['Authorization'] = "Bearer #{@api_key}"
            req.headers['Content-Type'] = 'application/json'
            req.body = JSON.generate(body)
          end
        end
      end
    end
  end
end
