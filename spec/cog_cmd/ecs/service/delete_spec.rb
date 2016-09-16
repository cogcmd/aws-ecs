require 'spec_helper'

describe 'the service-delete command' do
  let(:command_name) { 'service-delete' }

  let(:client) { double('Aws::Ecs::Client') }

  let(:service_response) do
    Aws::ECS::Types::DeleteServiceResponse.new
  end

  before do
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
  end

  it 'deletes a service' do
    expect(client).to receive(:delete_service).and_return(service_response)

    run_command(args: ['myservice'])
  end

  it 'returns an error when the service is not specified' do
    expect { run_command }.to raise_error(Cog::Error)
  end
end
