require 'spec_helper'

describe 'the container-list command' do
  let(:command_name) { 'container-list' }

  let(:client) { Object.new }

  before do
    allow(Aws::S3::Client).to receive(:new).and_return(client)
  end

  let(:object_list) do
    obj = Aws::S3::Types::Object.new(key: 'container-definitions/mydef.json',
                                     last_modified: '2016-09-06 23:39:15 UTC')
    Aws::S3::Types::ListObjectsV2Output.new(contents: Array.new.push(obj))
  end

  it 'returns a list of container definitions' do
    ENV['ECS_CONTAINER_DEF_URL'] = 's3://fakebucket/container-definitions'

    expect(client).to receive(:list_objects_v2).and_return(object_list)

    run_command

    expect(command).to respond_with([{ name: 'mydef',
                                       last_modified: '2016-09-06 23:39:15 UTC' }])
  end

end
