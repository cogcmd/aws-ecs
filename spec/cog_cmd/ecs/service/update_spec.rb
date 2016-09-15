require 'spec_helper'

describe 'the service-update command' do
  let(:command_name) { 'service-update' }

  let(:client) { double('Aws::Ecs::Client') }

  let(:service) do
    Aws::ECS::Types::UpdateServiceResponse.new
  end

  before do
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
  end

  it 'updates a service' do
    expect(client).to receive(:update_service).and_return(service)

    run_command(args: ['myservice'])
  end

  it 'returns an error when a service name is not specified' do
    expect { run_command }.to raise_error(Cog::Error)
  end

end
