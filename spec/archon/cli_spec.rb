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
      expect(cli.options[:model]).to eq('grok-3-mini')
      expect(cli.options[:provider]).to eq('grok')
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

      expect { cli.run }.to output("{\"outcome\":\"success\",\"value\":\"4\"}\n").to_stdout
    end

    it 'aborts when no prompt is provided' do
      allow($stdin).to receive(:tty?).and_return(true)
      cli = described_class.new([])

      expect { cli.run }.to raise_error(SystemExit)
    end
  end
end
