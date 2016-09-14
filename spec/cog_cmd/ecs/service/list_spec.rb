require 'spec_helper'

describe 'the service-list command' do
  let(:command_name) { 'service-list' }

  let(:client) { Object.new }

  let(:service_arns) do
    Aws::ECS::Types::ListServicesResponse.new(
      service_arns: [
        'arn:aws:ecs:us-east-1:000000000000:service/service1',
        'arn:aws:ecs:us-east-1:111111111111:service/service2',
        'arn:aws:ecs:us-east-1:222222222222:service/service3' ])
  end

  before do
    allow(Aws::ECS::Client).to receive(:new).and_return(client)
  end

  it 'returns a list of services' do
    expect(client).to receive(:list_services).and_return(service_arns)

    run_command

    expect(command).to respond_with([{ name: 'service1',
                                       arn: 'arn:aws:ecs:us-east-1:000000000000:service/service1' },
                                     { name: 'service2',
                                       arn: 'arn:aws:ecs:us-east-1:111111111111:service/service2' },
                                     { name: 'service3',
                                       arn: 'arn:aws:ecs:us-east-1:222222222222:service/service3' }])
  end
end
