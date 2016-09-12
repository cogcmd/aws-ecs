require 'spec_helper'

describe 'the task-list command' do
  let(:command_name) { 'task-list' }

  let(:client) do
    client = Object.new
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
    client
  end

  it 'returns a list of tasks and their revisions' do
    task_definitions =
      Aws::ECS::Types::ListTaskDefinitionsResponse.new(
        { task_definition_arns: [
          "arn:aws:ecs:us-east-1:<aws_account_id>:task-definition/family1:1",
          "arn:aws:ecs:us-east-1:<aws_account_id>:task-definition/family1:2",
          "arn:aws:ecs:us-east-1:<aws_account_id>:task-definition/family2:1",
          "arn:aws:ecs:us-east-1:<aws_account_id>:task-definition/family2:2",
          "arn:aws:ecs:us-east-1:<aws_account_id>:task-definition/family3:2"] })

    expect(client).to receive(:list_task_definitions).and_return(task_definitions)

    run_command
    expect(command).to respond_with(
      [{
        family: 'family1',
        revisions: [
          'family1:1',
          'family1:2']
      }, {
        family: 'family2',
        revisions: [
          'family2:1',
          'family2:2']
      }, {
        family: 'family3',
        revisions: [
          'family3:2']
      }])
  end

  it 'sends a family-prefix when the family option is specified' do
    expect(client).to receive(:list_task_definitions).with({family_prefix: 'myfamily'}).and_return(Aws::ECS::Types::ListTaskDefinitionsResponse.new)

    run_command(options: { family: 'myfamily' })
  end

  it 'sends a family-prefix when the family-prefix option is specified' do
    expect(client).to receive(:list_task_definitions).with({family_prefix: 'myfamily'}).and_return(Aws::ECS::Types::ListTaskDefinitionsResponse.new)

    run_command(options: { 'family-prefix': 'myfamily' })
  end

end
