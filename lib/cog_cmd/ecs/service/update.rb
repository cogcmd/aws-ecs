require 'cog_cmd/ecs/helpers'
require 'cog_cmd/ecs/service/helpers'

module CogCmd::Ecs::Service
  class Update < Cog::Command

    include CogCmd::Ecs::Helpers
    include CogCmd::Ecs::Service::Helpers

    attr_reader :service_name
    attr_reader :cluster_name, :task_definition, :desired_count

    def initialize
      # args
      @service_name = request.args[0]

      # options
      @cluster_name = request.options['cluster']
      @deployment_config = request.options['deployment-config']
      @task_definition = request.options['task-definition']
      @desired_count = request.options['desired-count']
    end

    def run_command
      raise(Cog::Error, "A service name must be specified.") unless service_name

      response.template = 'service_summary'
      response.content = update_service
    end

    private

    def update_service
      client = Aws::ECS::Client.new()

      params = {
        service: service_name
      }
      params['cluster'] = cluster_name                       if cluster_name
      params['deployment_configuration'] = deployment_config if deployment_config
      params['task_definition'] = task_definition            if task_definition
      params['desired_count'] = desired_count                if desired_count

      client.update_service(params).service.to_h
    end

  end
end
