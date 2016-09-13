require 'spec_helper'

describe 'the task-show command' do
  let(:command_name) { 'task-show' }

  let(:client) do
    client = Object.new
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
    client
  end

  let(:task_def_params) do
    {
      family: 'mytask',
      revision: 1,
      status: 'ACTIVE',
      task_definition_arn: 'arn:task-definition/mytask:1',
      container_definition: {
        name: 'def1',
        memory: 256,
        image: 'myimage'
      }
    }
  end

  let(:task_definition) do
    Aws::ECS::Types::DescribeTaskDefinitionResponse.new({ task_definition: task_def_params })
  end

  it 'returns an error when no arguments are specified' do
    expect { run_command }.to raise_error(Cog::Error)
  end

  it 'shows a task definition' do
    expect(client).to receive(:describe_task_definition).with(task_definition: 'mytask').and_return(task_definition)

    run_command(args: ['mytask'])
    expect(command).to respond_with(task_def_params)
  end
end
