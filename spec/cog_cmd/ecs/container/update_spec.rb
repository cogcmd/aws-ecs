require 'spec_helper'

describe 'the container-update command' do
  let(:command_name) { 'container-update' }

  let(:client) do
    client = Object.new
    allow(Aws::S3::Client).to receive(:new).and_return(client)
    client
  end

  it 'updates a container definition' do
    ENV['ECS_CONTAINER_DEF_URL'] = 's3://fakebucket/container-definitions'
    original_def = double(body: double(read: '{"name":"mydef","memory":256,"image":"myimage"}'))
    updated_def = double(body: double(read: '{"name":"mydef","memory":256,"image":"myupdatedimage"}'))
    key = 'container-definitions/mydef.json'

    expect(client).to receive(:get_object).and_return(original_def, updated_def)
    body_str = <<~END
    {
      "name": "mydef",
      "image": "myupdatedimage",
      "memory": 256
    }
    END
    expect(client).to receive(:put_object).with(bucket: 'fakebucket', key: key, body: body_str.chomp)

    run_command(args: ['mydef'], options: { image: 'myupdatedimage' })

    expect(command).to respond_with({ 'name' => 'mydef',
                                      'image' => 'myupdatedimage',
                                      'memory' => 256 })
  end

  it 'returns an error when the definition name is not passed' do
    expect { run_command }.to raise_error(Cog::Error)
  end

end
