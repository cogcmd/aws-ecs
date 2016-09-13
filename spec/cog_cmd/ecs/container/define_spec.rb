require 'spec_helper'

describe 'the container-define command' do
  let(:command_name) { 'container-define' }

  let(:client) do
    client = Object.new
    allow(Aws::S3::Client).to receive(:new).and_return(client)
    client
  end

  it 'defines a new container definition' do
    ENV['ECS_CONTAINER_DEF_URL'] = 's3://fakebucket/container-definitions'
    container_def = double(body: double(read: '{"name":"mydef","memory":256,"image":"myimage"}'))

    expect(client).to receive(:put_object)
    expect(client).to receive(:get_object).and_return(container_def)

    run_command(args: ['mydef', 'myimage'], options: { memory: 256 })

    expect(command).to respond_with({ 'name' => 'mydef',
                                      'image' => 'myimage',
                                      'memory' => 256 })
  end

  it 'returns an error when a definition name is not specified' do
    expect { run_command }.to raise_error(Cog::Error)
  end

  it 'returns an error when an image is not specified' do
    expect { run_command(args: ['mydef']) }.to raise_error(Cog::Error)
  end

end
