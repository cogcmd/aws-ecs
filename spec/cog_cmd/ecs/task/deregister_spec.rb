require 'spec_helper'

describe 'the task-deregister command' do
  let(:command_name) { 'task-deregister' }

  let(:client) do
    client = Object.new
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
    client
  end

  it 'returns an error when no arguments are specified' do
    expect { run_command }.to raise_error(Cog::Error)
  end

  it 'returns an error when a version is not specified' do
    expect { run_command(args: ['myfamily']) }.to raise_error(Cog::Error)
  end

  it 'deregisters a task' do
    expect(client).to receive(:deregister_task_definition).and_return(Aws::ECS::Types::DeregisterTaskDefinitionResponse.new)
    run_command(args: ['myfamily:1'])
  end
end
