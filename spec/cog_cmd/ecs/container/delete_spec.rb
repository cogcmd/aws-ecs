require 'spec_helper'

describe 'the container-delete command' do
  let(:command_name) { 'container-delete' }

  let(:client) { Object.new }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(client)
  end

  it 'deletes a container definition' do
    ENV['ECS_CONTAINER_DEF_URL'] = 's3://fakebucket/container-definitions'
    expect(client).to receive(:delete_object)

    run_command(args: ['mydef'])

    expect(command).to respond_with({ status: 'deleted',
                                      name: 'mydef' })
  end

  it 'returns an error when a definition name is not passed' do
    expect { run_command }.to raise_error(Cog::Error)
  end

end
