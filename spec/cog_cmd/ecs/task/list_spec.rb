require 'spec_helper'

describe 'the task-list command' do
  let(:command_name) { 'task-list' }

  let(:client) { double('Aws::ECS::Client') }

  let(:families) do
    Aws::ECS::Types::ListTaskDefinitionFamiliesResponse.new(
      families: [ 'myfamily',
                  'herfamily',
                  'hisfamily',
                  'theirfamily' ])
  end

  let(:revisions) do
    Aws::ECS::Types::ListTaskDefinitionsResponse.new(
      task_definition_arns: [ 'arn:aws:ecs:us-east-1:000000000000:task-definition/myfamily:1',
                              'arn:aws:ecs:us-east-1:000000000000:task-definition/myfamily:2',
                              'arn:aws:ecs:us-east-1:000000000000:task-definition/myfamily:3',
                              'arn:aws:ecs:us-east-1:000000000000:task-definition/myfamily:4',
                              'arn:aws:ecs:us-east-1:000000000000:task-definition/myfamily:5' ])
  end

  before do
    allow(client).to receive(:new).and_return(client)
  end

  it 'returns a list of task definition families when no args are passed' do
    expect(client).to receive(:list_task_definition_families).and_return(families)

    run_command

    expect(command).to respond_with([{ task_definition: 'myfamily',
                                       status: 'ACTIVE' },
                                     { task_definition: 'herfamily',
                                       status: 'ACTIVE' },
                                     { task_definition: 'hisfamily',
                                       status: 'ACTIVE' },
                                     { task_definition: 'theirfamily',
                                       status: 'ACTIVE' }])
  end

  it 'returns a list of task definition revisions when a task def is passed' do
    expect(client).to receive(:list_task_definitions).and_return(revisions)

    run_command(args: ['myfamily'])

    expect(command).to respond_with([{ task_definition: 'myfamily:1',
                                       status: 'ACTIVE' },
                                     { task_definition: 'myfamily:2',
                                       status: 'ACTIVE' },
                                     { task_definition: 'myfamily:3',
                                       status: 'ACTIVE' },
                                     { task_definition: 'myfamily:4',
                                       status: 'ACTIVE' },
                                     { task_definition: 'myfamily:5',
                                       status: 'ACTIVE' }])
  end

end
