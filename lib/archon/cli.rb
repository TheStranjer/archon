# frozen_string_literal: true

require 'optparse'
require 'json'

module Archon
  class CLI
    attr_reader :options

    DEFAULTS = {
      overflow: 10,
      model: 'grok-4-1-fast-reasoning',
      provider: 'grok'
    }.freeze

    def initialize(argv = ARGV)
      @options = DEFAULTS.dup
      build_parser.parse!(argv)
    end

    def run
      prompt = resolve_prompt
      abort 'Error: No prompt provided' if prompt.nil? || prompt.strip.empty?

      result = execute(prompt)
      $stdout.puts JSON.generate(
        outcome: result.outcome, result_type: result.result_type, value: result.value
      )
    end

    private

    def execute(prompt)
      client = build_client
      Agent.new(client: client, overflow: options[:overflow]).run(prompt)
    end

    def build_parser
      OptionParser.new do |opts|
        opts.banner = 'Usage: archon [options]'
        define_options(opts)
      end
    end

    def define_options(opts)
      define_prompt_options(opts)
      define_agent_options(opts)
      define_search_options(opts)
    end

    def define_prompt_options(opts)
      opts.on('--prompt-text TEXT', 'Prompt text') { |t| options[:prompt_text] = t }
      opts.on('--prompt-file FILE', 'Read prompt from file') { |f| options[:prompt_file] = f }
    end

    def define_agent_options(opts)
      opts.on('--overflow N', Integer, 'Max tool calls') { |n| options[:overflow] = n }
      opts.on('--model MODEL', 'Model name') { |m| options[:model] = m }
      opts.on('--provider PROVIDER', 'LLM provider') { |p| options[:provider] = p }
    end

    def define_search_options(opts)
      opts.on('--no-web-search', 'Disable web search (Grok only)') { options[:web_search] = false }
      opts.on('--no-x-search', 'Disable X search (Grok only)') { options[:x_search] = false }
    end

    def resolve_prompt
      options[:prompt_text] || read_file_prompt || read_stdin_prompt
    end

    def read_file_prompt
      options[:prompt_file] && File.read(options[:prompt_file])
    end

    def read_stdin_prompt
      $stdin.read unless $stdin.tty?
    end

    def build_client
      case options[:provider]
      when 'grok'
        LLMs::Grok::Client.new(
          model: options[:model],
          web_search: options.fetch(:web_search, true),
          x_search: options.fetch(:x_search, true)
        )
      else abort "Unknown provider: #{options[:provider]}"
      end
    end
  end
end
