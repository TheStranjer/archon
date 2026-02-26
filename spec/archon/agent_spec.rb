# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Archon::Agent do
  let(:client) { instance_double(Archon::LLMs::Base) }
  let(:agent) { described_class.new(client: client, overflow: 3) }

  def tool_call_response(name, arguments, id: 'call_1')
    {
      role: 'assistant', content: nil, finish_reason: 'tool_calls',
      tool_calls: [{ 'id' => id, 'function' => { 'name' => name, 'arguments' => arguments } }]
    }
  end

  describe '#run' do
    it 'returns a FinalAnswer::Result when LLM calls final_answer' do
      response = tool_call_response('final_answer', '{"outcome":"success","value":"4"}')
      allow(client).to receive(:chat).and_return(response)

      result = agent.run('What is 2+2?')

      expect(result).to be_a(Archon::FinalAnswer::Result)
      expect(result.outcome).to eq('success')
      expect(result.value).to eq('4')
    end

    it 'returns overflow result when tool call limit is reached' do
      response = tool_call_response('other_tool', '{}')
      allow(client).to receive(:chat).and_return(response)

      result = agent.run('Do something')

      expect(result.outcome).to eq('overflow')
    end

    it 'loops until final_answer is called' do
      non_final = tool_call_response('other_tool', '{}')
      final = tool_call_response('final_answer', '{"outcome":"success","value":"done"}',
                                 id: 'call_2')
      allow(client).to receive(:chat).and_return(non_final, final)

      result = agent.run('Do it')

      expect(result.value).to eq('done')
    end
  end
end
