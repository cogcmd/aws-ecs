require 'spec_helper'

describe 'the task-families command' do
  let(:command_name) { 'task-families' }

  let(:client) do
    client = Object.new
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
    client
  end

  let(:families_response) do
    Aws::ECS::Types::ListTaskDefinitionFamiliesResponse.new(families: [ 'family1',
                                                                        'family2' ])
  end

  it 'lists task families' do
    expect(client).to receive(:list_task_definition_families).and_return(families_response)
    run_command

    expect(command).to respond_with([{ family: 'family1'},{ family: 'family2' }])
  end

end
