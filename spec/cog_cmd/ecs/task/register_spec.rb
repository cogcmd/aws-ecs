require 'spec_helper'

describe 'the task-register command' do
  let(:command_name) { 'task-register' }

  let(:client) do
    client = Object.new
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
    client
  end

  let(:s3) do
    client = Object.new
    allow(Aws::S3::Client).to receive(:new).and_return(client)
    client
  end

  let(:task_definition) do
    Aws::ECS::Types::RegisterTaskDefinitionResponse.new()
  end

  it 'returns an error when no arguments are specified' do
    expect { run_command }.to raise_error(Cog::Error)
  end

  it 'returns an error when no container definitions are passed' do
    expect { run_command(args: ['myfamily']) }.to raise_error(Cog::Error)
  end

  it 'registers a task definition' do
    container_def = double(body: double(read: '{"name":"mydef","memory":256,"image":"myimage"}'))
    ENV['ECS_CONTAINER_DEF_URL'] = 's3://fakebucket/container-definitions'

    expect(s3).to receive(:get_object).and_return(container_def)
    expect(client).to receive(:register_task_definition).and_return(task_definition)

    run_command(args: ['mytask', 'mydef'])

    expect(command).to respond_with({})
  end

end
