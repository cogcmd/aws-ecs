require 'spec_helper'

describe 'the service-create command' do
  let(:command_name) { 'service-create' }

  let(:client) { Object.new }

  let(:service_response) do
    Aws::ECS::Types::CreateServiceResponse.new
  end

  before do
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
  end

  it 'creates a new service' do
    expect(client).to receive(:create_service).and_return(service_response)

    run_command(args: ['myservice', 'mytask'])
  end

  it 'returns an error if a service name is not specified' do
    expect { run_command }.to raise_error(Cog::Error)
  end

  it 'returns an error if a task name is not specified' do
    expect { run_command(args: ['myservice']) }.to raise_error(Cog::Error)
  end
end
