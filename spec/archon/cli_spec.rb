# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::CLI do
  describe '#initialize' do
    it 'parses --prompt-text' do
      cli = described_class.new(['--prompt-text', 'hello'])

      expect(cli.options[:prompt_text]).to eq('hello')
    end

    it 'parses --overflow' do
      cli = described_class.new(['--overflow', '5'])

      expect(cli.options[:overflow]).to eq(5)
    end

    it 'parses --model' do
      cli = described_class.new(['--model', 'grok-3'])

      expect(cli.options[:model]).to eq('grok-3')
    end

    it 'parses --provider' do
      cli = described_class.new(['--provider', 'grok'])

      expect(cli.options[:provider]).to eq('grok')
    end

    it 'uses defaults when no arguments given' do
      cli = described_class.new([])

      expect(cli.options[:overflow]).to eq(10)
      expect(cli.options[:model]).to eq('grok-4-1-fast-reasoning')
      expect(cli.options[:provider]).to eq('grok')
    end

    it 'parses --no-web-search' do
      cli = described_class.new(['--no-web-search'])

      expect(cli.options[:web_search]).to be(false)
    end

    it 'parses --no-x-search' do
      cli = described_class.new(['--no-x-search'])

      expect(cli.options[:x_search]).to be(false)
    end

    it 'enables web_search and x_search by default' do
      cli = described_class.new([])

      expect(cli.options).not_to have_key(:web_search)
      expect(cli.options).not_to have_key(:x_search)
    end
  end

  describe '#run' do
    it 'outputs JSON result to stdout' do
      cli = described_class.new(['--prompt-text', 'hello'])
      result = Archon::FinalAnswer::Result.new(outcome: 'success', value: '4')
      agent = instance_double(Archon::Agent, run: result)
      client = instance_double(Archon::LLMs::Grok::Client)

      allow(Archon::LLMs::Grok::Client).to receive(:new).and_return(client)
      allow(Archon::Agent).to receive(:new).and_return(agent)

      expected = "{\"outcome\":\"success\",\"result_type\":null,\"value\":\"4\"}\n"
      expect { cli.run }.to output(expected).to_stdout
    end

    it 'aborts when no prompt is provided' do
      allow($stdin).to receive(:tty?).and_return(true)
      cli = described_class.new([])

      expect { cli.run }.to raise_error(SystemExit)
    end
  end
end
