require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Service
  class Delete < Cog::Command

    include CogCmd::Ecs::Helpers

    attr_reader :service_name
    attr_reader :cluster_name

    def initialize
      # args
      @service_name = request.args[0]

      # options
      @cluster_name = request.options['cluster']
    end

    def run_command
      raise(Cog::Error, "A service name must be specified.") unless service_name

      response.template = 'service_show'
      response.content = delete_service
    end

    private

    def delete_service
      client = Aws::ECS::Client.new()

      params = {
        service: service_name
      }
      params['cluster'] = cluster_name if cluster_name

      client.delete_service(params).service.to_h
    end
  end
end
