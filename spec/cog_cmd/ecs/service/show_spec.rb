require 'spec_helper'

describe 'the service-show command' do
  let(:command_name) { 'service-show' }

  let(:client) { double('Aws::Ecs::Client') }

  let(:service_response) do
    Aws::ECS::Types::DescribeServicesResponse.new(
      services: [])
  end

  before do
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
  end

  it 'shows a service' do
    expect(client).to receive(:describe_services).and_return(service_response)

    run_command(args: ['myservice'])
  end

  it 'returns an error when a service name is not passed' do
    expect { run_command }.to raise_error(Cog::Error)
  end

end
