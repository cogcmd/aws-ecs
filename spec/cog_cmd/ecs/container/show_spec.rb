require 'spec_helper'

describe 'the container-show command' do
  let(:command_name) { 'container-show' }

  let(:client) { Object.new }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(client)
  end

  it 'shows a container definition' do
    ENV['ECS_CONTAINER_DEF_URL'] = 's3://fakebucket/container-definitions'
    container_def = double(body: double(read: '{"name":"mydef","memory":256,"image":"myimage"}'))

    expect(client).to receive(:get_object).and_return(container_def)

    run_command(args: ['mydef'])

    expect(command).to respond_with({ 'name' => 'mydef',
                                      'image' => 'myimage',
                                      'memory' => 256 })
  end

end
